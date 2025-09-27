import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/download_models.dart';

class VideoDownloadService {
  static VideoDownloadService? _instance;
  static VideoDownloadService get instance =>
      _instance ??= VideoDownloadService._();

  VideoDownloadService._();

  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Download management
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, Timer> _speedCalculationTimers = {};
  final Map<String, int> _lastDownloadedBytes = {};
  final Map<String, DateTime> _lastSpeedUpdate = {};

  // Streams for real-time updates
  final StreamController<List<DownloadTask>> _downloadsController =
      StreamController<List<DownloadTask>>.broadcast();
  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  // Storage
  late Box<DownloadTask> _downloadsBox;
  late Box<DownloadSettings> _settingsBox;
  DownloadSettings? _currentSettings;

  // State management
  final List<DownloadTask> _activeTasks = [];
  bool _isInitialized = false;

  // Getters for streams
  Stream<List<DownloadTask>> get downloadsStream => _downloadsController.stream;
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  List<DownloadTask> get allDownloads => _activeTasks;
  List<DownloadTask> get activeDownloads => _activeTasks
      .where(
        (task) =>
            task.status == DownloadStatus.downloading ||
            task.status == DownloadStatus.queued,
      )
      .toList();
  List<DownloadTask> get completedDownloads => _activeTasks
      .where((task) => task.status == DownloadStatus.completed)
      .toList();

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _initializeNotifications();
    await _initializeStorage();
    await _requestPermissions();

    _isInitialized = true;
    print('🎯 VideoDownloadService initialized successfully');
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _initializeStorage() async {
    _downloadsBox = await Hive.openBox<DownloadTask>('downloads');
    _settingsBox = await Hive.openBox<DownloadSettings>('download_settings');

    // Load existing downloads
    _activeTasks.clear();
    _activeTasks.addAll(_downloadsBox.values);

    // Load settings
    _currentSettings =
        _settingsBox.get('settings') ?? await _getDefaultSettings();

    _downloadsController.add(_activeTasks);
  }

  Future<DownloadSettings> _getDefaultSettings() async {
    final directory = await getApplicationDocumentsDirectory();
    return DownloadSettings(downloadLocation: '${directory.path}/downloads');
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        final status2 = await Permission.manageExternalStorage.request();
        return status2.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  Future<bool> _checkNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final settings = await getSettings();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    if (settings.downloadOnlyOnWifi &&
        connectivityResult != ConnectivityResult.wifi) {
      return false;
    }

    return true;
  }

  Future<String> startDownload({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    required String videoUrl,
    DownloadQuality? quality,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check network connectivity
    if (!await _checkNetworkConnectivity()) {
      throw Exception('Network conditions not suitable for downloading');
    }

    // Check if already downloading or downloaded
    final existingTask = _activeTasks.firstWhere(
      (task) => task.videoId == videoId,
      orElse: () => DownloadTask(
        id: '',
        videoId: '',
        title: '',
        thumbnailUrl: '',
        videoUrl: '',
        quality: DownloadQuality.medium,
        createdAt: DateTime.now(),
      ),
    );

    if (existingTask.id.isNotEmpty) {
      if (existingTask.status == DownloadStatus.completed) {
        throw Exception('Video already downloaded');
      } else if (existingTask.status == DownloadStatus.downloading) {
        throw Exception('Video is already being downloaded');
      }
    }

    // Check concurrent downloads limit
    final settings = await getSettings();
    final activeCount = activeDownloads.length;
    if (activeCount >= settings.maxConcurrentDownloads) {
      // Queue the download
      final task = DownloadTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoId: videoId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        quality: quality ?? settings.defaultQuality,
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
      );

      await _saveTask(task);
      return task.id;
    }

    // Start immediate download
    return await _executeDownload(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      quality: quality ?? settings.defaultQuality,
    );
  }

  Future<String> _executeDownload({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    required String videoUrl,
    required DownloadQuality quality,
  }) async {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    final task = DownloadTask(
      id: taskId,
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      quality: quality,
      status: DownloadStatus.downloading,
      createdAt: DateTime.now(),
    );

    await _saveTask(task);

    try {
      // Create download directory
      final settings = await getSettings();
      final downloadDir = Directory(settings.downloadLocation);
      if (!downloadDir.existsSync()) {
        await downloadDir.create(recursive: true);
      }

      // Generate file path
      final fileName =
          '${_sanitizeFileName(title)}_${quality.name}_$videoId.mp4';
      final filePath = '${downloadDir.path}/$fileName';

      // Start speed calculation timer
      _startSpeedCalculation(taskId);

      // Download the file
      await _dio.download(
        videoUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          _onReceiveProgress(taskId, received, total);
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 30),
          sendTimeout: const Duration(minutes: 5),
        ),
      );

      // Download completed successfully
      final completedTask = task.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        localPath: filePath,
        completedAt: DateTime.now(),
      );

      await _saveTask(completedTask);
      await _showDownloadCompleteNotification(completedTask);

      // Start next queued download if any
      await _processQueue();
    } catch (e) {
      print('❌ Download failed for $taskId: $e');

      final failedTask = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );

      await _saveTask(failedTask);
      await _showDownloadFailedNotification(failedTask);

      // Start next queued download if any
      await _processQueue();
    } finally {
      _cancelTokens.remove(taskId);
      _speedCalculationTimers[taskId]?.cancel();
      _speedCalculationTimers.remove(taskId);
      _lastDownloadedBytes.remove(taskId);
      _lastSpeedUpdate.remove(taskId);
    }

    return taskId;
  }

  void _onReceiveProgress(String taskId, int received, int total) {
    final task = _activeTasks.firstWhere((t) => t.id == taskId);
    final progress = total > 0 ? received / total : 0.0;

    // Update download bytes for speed calculation
    _lastDownloadedBytes[taskId] = received;

    final updatedTask = task.copyWith(
      progress: progress,
      downloadedBytes: received,
      totalBytes: total,
    );

    _updateTask(updatedTask);

    // Emit progress update
    _progressController.add(
      DownloadProgress(
        taskId: taskId,
        progress: progress,
        downloadedBytes: received,
        totalBytes: total,
        speed: updatedTask.downloadSpeed,
        estimatedTimeRemaining: updatedTask.estimatedTimeRemaining,
      ),
    );
  }

  void _startSpeedCalculation(String taskId) {
    _lastDownloadedBytes[taskId] = 0;
    _lastSpeedUpdate[taskId] = DateTime.now();

    _speedCalculationTimers[taskId] = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _calculateSpeed(taskId),
    );
  }

  void _calculateSpeed(String taskId) {
    final currentBytes = _lastDownloadedBytes[taskId] ?? 0;
    final currentTime = DateTime.now();
    final lastTime = _lastSpeedUpdate[taskId];

    if (lastTime == null) return;

    final task = _activeTasks.firstWhere((t) => t.id == taskId);
    final timeDiff = currentTime.difference(lastTime).inSeconds;

    if (timeDiff > 0) {
      final bytesDiff = currentBytes - (task.downloadedBytes);
      final speed = bytesDiff / timeDiff;

      // Calculate ETA
      final remainingBytes = task.totalBytes - currentBytes;
      final eta = speed > 0
          ? Duration(seconds: (remainingBytes / speed).round())
          : Duration.zero;

      final updatedTask = task.copyWith(
        downloadSpeed: speed,
        estimatedTimeRemaining: eta,
      );

      _updateTask(updatedTask);
      _lastSpeedUpdate[taskId] = currentTime;
    }
  }

  Future<void> pauseDownload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download paused by user');
    }

    final task = _activeTasks.firstWhere((t) => t.id == taskId);
    final pausedTask = task.copyWith(status: DownloadStatus.paused);
    await _saveTask(pausedTask);
  }

  Future<void> resumeDownload(String taskId) async {
    final task = _activeTasks.firstWhere((t) => t.id == taskId);

    if (task.status != DownloadStatus.paused) return;

    // Check network connectivity
    if (!await _checkNetworkConnectivity()) {
      throw Exception('Network conditions not suitable for downloading');
    }

    final resumedTask = task.copyWith(status: DownloadStatus.downloading);
    await _saveTask(resumedTask);

    // Continue download from where it left off
    await _executeDownload(
      videoId: task.videoId,
      title: task.title,
      thumbnailUrl: task.thumbnailUrl,
      videoUrl: task.videoUrl,
      quality: task.quality,
    );
  }

  Future<void> cancelDownload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
    }

    final task = _activeTasks.firstWhere((t) => t.id == taskId);

    // Delete partial file if exists
    if (task.localPath != null) {
      final file = File(task.localPath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    final cancelledTask = task.copyWith(status: DownloadStatus.cancelled);
    await _saveTask(cancelledTask);

    // Start next queued download if any
    await _processQueue();
  }

  Future<void> deleteDownload(String taskId) async {
    final task = _activeTasks.firstWhere((t) => t.id == taskId);

    // Delete file if exists
    if (task.localPath != null) {
      final file = File(task.localPath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }

    // Remove from storage and memory
    await _downloadsBox.delete(taskId);
    _activeTasks.removeWhere((t) => t.id == taskId);
    _downloadsController.add(_activeTasks);
  }

  Future<void> _processQueue() async {
    final queuedTasks = _activeTasks
        .where((task) => task.status == DownloadStatus.queued)
        .toList();

    final settings = await getSettings();
    final activeCount = activeDownloads.length;

    if (queuedTasks.isNotEmpty &&
        activeCount < settings.maxConcurrentDownloads) {
      final nextTask = queuedTasks.first;
      await _executeDownload(
        videoId: nextTask.videoId,
        title: nextTask.title,
        thumbnailUrl: nextTask.thumbnailUrl,
        videoUrl: nextTask.videoUrl,
        quality: nextTask.quality,
      );
    }
  }

  Future<void> _saveTask(DownloadTask task) async {
    await _downloadsBox.put(task.id, task);

    final index = _activeTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _activeTasks[index] = task;
    } else {
      _activeTasks.add(task);
    }

    _downloadsController.add(_activeTasks);
  }

  void _updateTask(DownloadTask task) {
    final index = _activeTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _activeTasks[index] = task;
      _downloadsController.add(_activeTasks);
    }
  }

  Future<void> _showDownloadCompleteNotification(DownloadTask task) async {
    const androidDetails = AndroidNotificationDetails(
      'download_complete',
      'Download Complete',
      channelDescription: 'Notifications for completed downloads',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      task.id.hashCode,
      'Download Complete',
      '${task.title} has been downloaded successfully',
      details,
    );
  }

  Future<void> _showDownloadFailedNotification(DownloadTask task) async {
    const androidDetails = AndroidNotificationDetails(
      'download_failed',
      'Download Failed',
      channelDescription: 'Notifications for failed downloads',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      task.id.hashCode,
      'Download Failed',
      'Failed to download ${task.title}',
      details,
    );
  }

  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<DownloadSettings> getSettings() async {
    return _currentSettings ?? await _getDefaultSettings();
  }

  Future<void> updateSettings(DownloadSettings settings) async {
    _currentSettings = settings;
    await _settingsBox.put('settings', settings);
  }

  bool isVideoDownloaded(String videoId) {
    return _activeTasks.any(
      (task) =>
          task.videoId == videoId && task.status == DownloadStatus.completed,
    );
  }

  DownloadTask? getDownloadedVideo(String videoId) {
    try {
      return _activeTasks.firstWhere(
        (task) =>
            task.videoId == videoId && task.status == DownloadStatus.completed,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    for (final timer in _speedCalculationTimers.values) {
      timer.cancel();
    }
    _speedCalculationTimers.clear();

    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel();
      }
    }
    _cancelTokens.clear();

    await _downloadsController.close();
    await _progressController.close();
  }
}

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum ConnectivityStatus { 
  online, 
  offline, 
  slow, 
  unstable,
  connecting,
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 3),
    checkInterval: const Duration(seconds: 2),
  );

  late StreamController<ConnectivityStatus> _statusController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;
  
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  ConnectivityStatus _currentStatus = ConnectivityStatus.offline;
  ConnectivityStatus get currentStatus => _currentStatus;

  Timer? _speedTestTimer;
  DateTime? _lastSpeedTest;
  DateTime? _lastDisconnectTime;
  DateTime? _lastConnectTime;
  bool _wasOfflineRecently = false;

  void initialize() {
    _statusController = StreamController<ConnectivityStatus>.broadcast();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        print('🚨 Connectivity error: $error');
        _updateStatus(ConnectivityStatus.offline);
      },
    );

    // Listen to internet connection status
    _internetSubscription = _connectionChecker.onStatusChange.listen(
      _handleInternetStatusChange,
      onError: (error) {
        print('🚨 Internet checker error: $error');
        _updateStatus(ConnectivityStatus.offline);
      },
    );

    // Initial check
    _checkInitialConnection();

    // Periodic quality monitoring
    _startPeriodicMonitoring();
  }

  void dispose() {
    _statusController.close();
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _speedTestTimer?.cancel();
  }

  Future<void> _checkInitialConnection() async {
    try {
      print('🔍 Checking initial connection...');
      _updateStatus(ConnectivityStatus.connecting);
      
      final connectivityResult = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(connectivityResult);
    } catch (e) {
      print('❌ Initial connection check failed: $e');
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    print('📱 Connectivity changed: $result');
    
    if (result == ConnectivityResult.none) {
      _updateStatus(ConnectivityStatus.offline);
      return;
    }

    // Show connecting status briefly
    _updateStatus(ConnectivityStatus.connecting);
    
    // Wait a bit to avoid rapid state changes
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check actual internet connectivity
    final hasInternet = await _checkRealInternetConnection();
    if (!hasInternet) {
      _updateStatus(ConnectivityStatus.offline);
      return;
    }

    // Test connection quality
    final quality = await _testConnectionQuality();
    _updateStatusBasedOnQuality(quality);
  }

  void _handleInternetStatusChange(InternetConnectionStatus status) {
    print('🌐 Internet status changed: $status');
    
    switch (status) {
      case InternetConnectionStatus.connected:
        if (_currentStatus == ConnectivityStatus.offline) {
          _testConnectionQuality().then((quality) {
            _updateStatusBasedOnQuality(quality);
          });
        }
        break;
      case InternetConnectionStatus.disconnected:
        _updateStatus(ConnectivityStatus.offline);
        break;
    }
  }

  Future<bool> _checkRealInternetConnection() async {
    try {
      // Test multiple endpoints for reliability
      final endpoints = [
        'google.com',
        'cloudflare.com', 
        '8.8.8.8',
      ];
      
      for (final endpoint in endpoints) {
        try {
          final result = await InternetAddress.lookup(endpoint)
              .timeout(const Duration(seconds: 3));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (e) {
          continue; // Try next endpoint
        }
      }
      return false;
    } catch (e) {
      print('🔍 Real internet check error: $e');
      return false;
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      final oldStatus = _currentStatus;
      _currentStatus = status;
      
      // Track timing for notifications
      if (status == ConnectivityStatus.offline) {
        _lastDisconnectTime = DateTime.now();
        _wasOfflineRecently = true;
      } else if (oldStatus == ConnectivityStatus.offline && 
                 (status == ConnectivityStatus.online || 
                  status == ConnectivityStatus.slow || 
                  status == ConnectivityStatus.unstable)) {
        _lastConnectTime = DateTime.now();
      }
      
      print('📊 Status updated: $oldStatus -> $status');
      _statusController.add(status);
    }
  }

  Future<double> _testConnectionQuality() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Test with small socket connection for accurate timing
      final socket = await Socket.connect('8.8.8.8', 53, 
          timeout: const Duration(seconds: 5));
      socket.destroy();
      
      stopwatch.stop();
      final timeInMs = stopwatch.elapsedMilliseconds;
      
      print('⚡ Connection test: ${timeInMs}ms');
      
      // Quality scoring based on latency
      if (timeInMs < 100) return 5.0;  // Excellent
      if (timeInMs < 300) return 4.0;  // Good
      if (timeInMs < 1000) return 3.0; // Average
      if (timeInMs < 3000) return 2.0; // Slow
      return 1.0; // Very slow
    } catch (e) {
      print('⚠️ Quality test error: $e');
      return 1.0; // Assume slow if test fails
    }
  }

  void _updateStatusBasedOnQuality(double quality) {
    ConnectivityStatus newStatus;
    if (quality >= 4.0) {
      newStatus = ConnectivityStatus.online;
    } else if (quality >= 3.0) {
      newStatus = ConnectivityStatus.unstable;
    } else {
      newStatus = ConnectivityStatus.slow;
    }
    _updateStatus(newStatus);
  }

  void _startPeriodicMonitoring() {
    _speedTestTimer = Timer.periodic(
      const Duration(seconds: 30), // More frequent monitoring
      (_) => _performPeriodicCheck(),
    );
  }

  Future<void> _performPeriodicCheck() async {
    final now = DateTime.now();
    if (_lastSpeedTest != null &&
        now.difference(_lastSpeedTest!).inSeconds < 20) {
      return; // Avoid too frequent tests
    }

    _lastSpeedTest = now;

    if (_currentStatus != ConnectivityStatus.offline) {
      final quality = await _testConnectionQuality();
      _updateStatusBasedOnQuality(quality);
    }
  }

  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return await _checkRealInternetConnection();
    } catch (e) {
      print('🔍 Connection check error: $e');
      return false;
    }
  }

  // Force refresh status
  Future<void> refreshStatus() async {
    await _checkInitialConnection();
  }

  // Check if we just reconnected (for showing connection restored notification)
  bool shouldShowReconnectionNotification() {
    if (_lastConnectTime != null && _wasOfflineRecently) {
      final timeSinceConnect = DateTime.now().difference(_lastConnectTime!);
      if (timeSinceConnect.inSeconds < 2) {
        _wasOfflineRecently = false; // Reset flag
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> getConnectionInfo() {
    return {
      'status': _currentStatus.toString(),
      'isOnline': _currentStatus != ConnectivityStatus.offline,
      'lastDisconnectTime': _lastDisconnectTime?.toIso8601String(),
      'lastConnectTime': _lastConnectTime?.toIso8601String(),
      'quality': _getQualityString(),
    };
  }

  String _getQualityString() {
    switch (_currentStatus) {
      case ConnectivityStatus.online:
        return 'Excellent';
      case ConnectivityStatus.unstable:
        return 'Good';
      case ConnectivityStatus.slow:
        return 'Slow';
      case ConnectivityStatus.connecting:
        return 'Connecting...';
      case ConnectivityStatus.offline:
        return 'Offline';
    }
  }

  String getStatusMessage(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return 'Connected - Good speed';
      case ConnectivityStatus.unstable:
        return 'Connected - Unstable connection';
      case ConnectivityStatus.slow:
        return 'Connected - Slow connection';
      case ConnectivityStatus.connecting:
        return 'Connecting...';
      case ConnectivityStatus.offline:
        return 'No internet connection';
    }
  }

  Color getStatusColor(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Colors.green;
      case ConnectivityStatus.unstable:
        return Colors.orange;
      case ConnectivityStatus.slow:
        return Colors.amber;
      case ConnectivityStatus.connecting:
        return Colors.blue;
      case ConnectivityStatus.offline:
        return Colors.red;
    }
  }

  IconData getStatusIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.online:
        return Icons.wifi;
      case ConnectivityStatus.unstable:
        return Icons.wifi_2_bar;
      case ConnectivityStatus.slow:
        return Icons.wifi_1_bar;
      case ConnectivityStatus.connecting:
        return Icons.wifi_find;
      case ConnectivityStatus.offline:
        return Icons.wifi_off;
    }
  }
}

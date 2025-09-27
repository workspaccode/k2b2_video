import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../models/download_models.dart';
import '../services/video_download_service.dart';

class DownloadSettingsSheet extends StatefulWidget {
  const DownloadSettingsSheet({super.key});

  @override
  State<DownloadSettingsSheet> createState() => _DownloadSettingsSheetState();
}

class _DownloadSettingsSheetState extends State<DownloadSettingsSheet> {
  final VideoDownloadService _downloadService = VideoDownloadService.instance;
  DownloadSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _downloadService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await _downloadService.updateSettings(_settings!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Color(0xFF6C5CE7),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(IconlyBold.setting, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Download Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(IconlyBold.close_square, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
            )
          else if (_settings != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQualitySection(),
                    const SizedBox(height: 24),
                    _buildNetworkSection(),
                    const SizedBox(height: 24),
                    _buildDownloadSection(),
                    const SizedBox(height: 24),
                    _buildStorageSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQualitySection() {
    return _buildSection(
      title: 'Video Quality',
      icon: IconlyBold.video,
      children: [
        _buildQualityOption(
          DownloadQuality.low,
          '480p',
          'Smaller files, faster downloads',
        ),
        _buildQualityOption(
          DownloadQuality.medium,
          '720p',
          'Good quality, balanced size',
        ),
        _buildQualityOption(
          DownloadQuality.high,
          '1080p',
          'High quality, larger files',
        ),
        _buildQualityOption(
          DownloadQuality.ultra,
          '4K',
          'Ultra HD, very large files',
        ),
      ],
    );
  }

  Widget _buildNetworkSection() {
    return _buildSection(
      title: 'Network Settings',
      icon: IconlyBold.discovery,
      children: [
        _buildSwitchTile(
          title: 'Download only on Wi-Fi',
          subtitle: 'Prevent downloads on mobile data',
          value: _settings!.downloadOnlyOnWifi,
          onChanged: (value) {
            setState(() {
              _settings = _settings!.copyWith(downloadOnlyOnWifi: value);
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Allow mobile data downloads',
          subtitle: 'Enable downloads on cellular network',
          value: _settings!.allowDownloadOnMobileData,
          onChanged: _settings!.downloadOnlyOnWifi
              ? null
              : (value) {
                  setState(() {
                    _settings = _settings!.copyWith(
                      allowDownloadOnMobileData: value,
                    );
                  });
                },
        ),
      ],
    );
  }

  Widget _buildDownloadSection() {
    return _buildSection(
      title: 'Download Management',
      icon: IconlyBold.download,
      children: [
        _buildSliderTile(
          title: 'Concurrent Downloads',
          subtitle: 'Maximum simultaneous downloads',
          value: _settings!.maxConcurrentDownloads.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (value) {
            setState(() {
              _settings = _settings!.copyWith(
                maxConcurrentDownloads: value.toInt(),
              );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Auto-download Watch Later',
          subtitle: 'Automatically download videos added to Watch Later',
          value: _settings!.autoDownloadWatchLater,
          onChanged: (value) {
            setState(() {
              _settings = _settings!.copyWith(autoDownloadWatchLater: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildStorageSection() {
    return _buildSection(
      title: 'Storage Management',
      icon: IconlyBold.folder,
      children: [
        _buildSwitchTile(
          title: 'Auto-delete old downloads',
          subtitle: 'Delete downloads after specified days',
          value: _settings!.deleteAfterDays,
          onChanged: (value) {
            setState(() {
              _settings = _settings!.copyWith(deleteAfterDays: value);
            });
          },
        ),
        if (_settings!.deleteAfterDays) ...[
          const SizedBox(height: 16),
          _buildSliderTile(
            title: 'Delete after days',
            subtitle: 'Number of days before auto-deletion',
            value: _settings!.deleteAfterDaysCount.toDouble(),
            min: 7,
            max: 90,
            divisions: 11,
            onChanged: (value) {
              setState(() {
                _settings = _settings!.copyWith(
                  deleteAfterDaysCount: value.toInt(),
                );
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildQualityOption(
    DownloadQuality quality,
    String title,
    String subtitle,
  ) {
    final isSelected = _settings!.defaultQuality == quality;

    return GestureDetector(
      onTap: () {
        setState(() {
          _settings = _settings!.copyWith(defaultQuality: quality);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C5CE7).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C5CE7)
                : const Color(0xFF3D3D3D),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? IconlyBold.tick_square : IconlyBroken.tick_square,
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: onChanged != null ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF6C5CE7),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6C5CE7), width: 1),
              ),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6C5CE7),
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            thumbColor: const Color(0xFF6C5CE7),
            overlayColor: const Color(0xFF6C5CE7).withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await _saveSettings();
          if (mounted) {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

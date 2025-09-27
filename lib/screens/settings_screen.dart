import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;

  // Settings states
  bool _notificationsEnabled = true;
  bool _autoDownload = false;
  bool _darkMode = true;
  String _videoQuality = 'Auto';
  String _language = 'العربية';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0F),
              const Color(0xFF1A1A2E).withValues(alpha: 0.9),
              const Color(0xFF16213E).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    _buildHeader()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 40),

                    // General Settings
                    _buildSettingsSection(
                          title: 'الإعدادات العامة',
                          children: [
                            _buildSwitchSetting(
                              icon: IconlyBold.notification,
                              title: 'الإشعارات',
                              subtitle: 'تلقي إشعارات المحتوى الجديد',
                              value: _notificationsEnabled,
                              onChanged: (value) =>
                                  setState(() => _notificationsEnabled = value),
                            ),
                            _buildSwitchSetting(
                              icon: IconlyBold.download,
                              title: 'التحميل التلقائي',
                              subtitle:
                                  'تحميل المقاطع تلقائياً عند الاتصال بالواي فاي',
                              value: _autoDownload,
                              onChanged: (value) =>
                                  setState(() => _autoDownload = value),
                            ),
                            _buildSwitchSetting(
                              icon: IconlyBold.show,
                              title: 'المظهر الداكن',
                              subtitle: 'استخدام المظهر الداكن',
                              value: _darkMode,
                              onChanged: (value) =>
                                  setState(() => _darkMode = value),
                            ),
                          ],
                        )
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Video Settings
                    _buildSettingsSection(
                          title: 'إعدادات الفيديو',
                          children: [
                            _buildOptionSetting(
                              icon: IconlyBold.video,
                              title: 'جودة الفيديو',
                              subtitle: 'اختر جودة التشغيل الافتراضية',
                              value: _videoQuality,
                              options: ['Auto', '4K', '1080p', '720p', '480p'],
                              onChanged: (value) =>
                                  setState(() => _videoQuality = value),
                            ),
                            _buildOptionSetting(
                              icon: IconlyBold.voice,
                              title: 'اللغة',
                              subtitle: 'لغة واجهة التطبيق',
                              value: _language,
                              options: ['العربية', 'English', 'Français'],
                              onChanged: (value) =>
                                  setState(() => _language = value),
                            ),
                          ],
                        )
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Account & Privacy
                    _buildSettingsSection(
                          title: 'الحساب والخصوصية',
                          children: [
                            _buildActionSetting(
                              icon: IconlyBold.profile,
                              title: 'إدارة الحساب',
                              subtitle: 'تعديل معلومات الحساب الشخصي',
                              onTap: () => _showSnackBar('قريباً'),
                            ),
                            _buildActionSetting(
                              icon: IconlyBold.shield_done,
                              title: 'الخصوصية والأمان',
                              subtitle: 'إعدادات الحماية والخصوصية',
                              onTap: () => _showSnackBar('قريباً'),
                            ),
                            _buildActionSetting(
                              icon: IconlyBold.delete,
                              title: 'مسح البيانات المحفوظة',
                              subtitle: 'حذف الملفات المؤقتة والتحميلات',
                              onTap: _showClearDataDialog,
                            ),
                          ],
                        )
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Support & About
                    _buildSettingsSection(
                          title: 'المساعدة والمعلومات',
                          children: [
                            _buildActionSetting(
                              icon: IconlyBold.info_square,
                              title: 'المساعدة والدعم',
                              subtitle: 'الحصول على مساعدة وتقديم الملاحظات',
                              onTap: () => _showSnackBar('قريباً'),
                            ),
                            _buildActionSetting(
                              icon: IconlyBold.document,
                              title: 'شروط الخدمة',
                              subtitle: 'اقرأ شروط وأحكام الاستخدام',
                              onTap: () => _showSnackBar('قريباً'),
                            ),
                            _buildActionSetting(
                              icon: IconlyBold.heart,
                              title: 'قيم التطبيق',
                              subtitle: 'ساعدنا بتقييم التطبيق',
                              onTap: () => _showSnackBar('شكراً لك!'),
                            ),
                          ],
                        )
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 800.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(4, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 1.57);
            final size = 100.0 + (index * 60);
            final opacity = 0.03 - (index * 0.007);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (160 + index * 80) * (index.isEven ? 1 : -1) * 0.6,
              top:
                  MediaQuery.of(context).size.height * 0.4 +
                  (120 + index * 70) * (index.isEven ? 1 : -1) * 0.5,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withValues(alpha: opacity),
                        const Color(
                          0xFFFF6B6B,
                        ).withValues(alpha: opacity * 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: GlassmorphicContainer(
            width: 48,
            height: 48,
            borderRadius: 16,
            blur: 10,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                const Color(0xFFFFFFFF).withValues(alpha: 0.05),
              ],
            ),
            borderGradient: LinearGradient(
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
              ],
            ),
            child: const Icon(
              IconlyLight.arrow_left_2,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'الإعدادات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.1),
          const Color(0xFFFFFFFF).withValues(alpha: 0.05),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.2),
          const Color(0xFFFFFFFF).withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
          ),
          const SizedBox(width: 16),
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
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4ECDC4),
            activeTrackColor: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showOptionsDialog(title, value, options, onChanged),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
              ),
              const SizedBox(width: 16),
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
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                IconlyLight.arrow_right_2,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: const Color(0xFF9B59B6), size: 20),
              ),
              const SizedBox(width: 16),
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
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                IconlyLight.arrow_right_2,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option, style: const TextStyle(color: Colors.white)),
              value: option,
              groupValue: currentValue,
              activeColor: const Color(0xFF4ECDC4),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'مسح البيانات',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع البيانات المحفوظة؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('تم مسح البيانات بنجاح');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

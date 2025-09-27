import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
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

                    // Profile Card
                    _buildProfileCard()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Stats Cards
                    _buildStatsCards()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 800.ms, delay: 600.ms)
                        .slideX(begin: 0.3, end: 0),

                    const SizedBox(height: 24),

                    // Settings Menu
                    _buildSettingsMenu()
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
          children: List.generate(6, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 1.047);
            final size = 120.0 + (index * 40);
            final opacity = 0.03 - (index * 0.005);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (180 + index * 60) * (index.isEven ? 1 : -1) * 0.6,
              top:
                  MediaQuery.of(context).size.height * 0.4 +
                  (100 + index * 50) * (index.isEven ? 1 : -1) * 0.5,
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
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GlassmorphicContainer(
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
          child: const Icon(IconlyLight.setting, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
      borderRadius: 24,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user?.photoURL != null
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                          ),
                    image: user?.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(user!.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user?.photoURL == null
                      ? const Icon(
                          IconlyBold.profile,
                          color: Colors.white,
                          size: 35,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                      ),
                      border: Border.all(
                        color: const Color(0xFF0A0A0F),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      IconlyBold.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Info
            Text(
              user?.displayName ?? 'اسم المستخدم',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? 'user@example.com',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Subscription Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD93D).withValues(alpha: 0.2),
                    const Color(0xFFFFA726).withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconlyBold.star,
                    color: const Color(0xFFFFD93D),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'عضوية مجانية',
                    style: TextStyle(
                      color: Color(0xFFFFD93D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: IconlyBold.play,
            title: '١٢٣',
            subtitle: 'مقطع مُشاهد',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: IconlyBold.download,
            title: '٤٥',
            subtitle: 'تحميل',
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: IconlyBold.time_circle,
            title: '٨٧ س',
            subtitle: 'وقت المشاهدة',
            color: const Color(0xFF9B59B6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
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
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: IconlyBold.bookmark,
            title: 'قائمة المشاهدة',
            onTap: () => _showSnackBar('قريباً'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            icon: IconlyBold.heart,
            title: 'المفضلة',
            onTap: () => _showSnackBar('قريباً'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 80,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4ECDC4), size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 320,
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
            const Text(
              'الإعدادات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            _buildSettingsItem(
              icon: IconlyBold.edit,
              title: 'تعديل الملف الشخصي',
              onTap: () => _showSnackBar('قريباً'),
            ),

            _buildSettingsItem(
              icon: IconlyBold.notification,
              title: 'الإشعارات',
              onTap: () => _showSnackBar('قريباً'),
            ),

            _buildSettingsItem(
              icon: IconlyBold.download,
              title: 'إدارة التحميلات',
              onTap: () => _showSnackBar('قريباً'),
            ),

            _buildSettingsItem(
              icon: IconlyBold.shield_done,
              title: 'الخصوصية والأمان',
              onTap: () => _showSnackBar('قريباً'),
            ),

            _buildSettingsItem(
              icon: IconlyBold.info_square,
              title: 'المساعدة والدعم',
              onTap: () => _showSnackBar('قريباً'),
            ),

            _buildSettingsItem(
              icon: IconlyBold.logout,
              title: 'تسجيل الخروج',
              onTap: _handleLogout,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFFF6B6B)
                  : Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? const Color(0xFFFF6B6B) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
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
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
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
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
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

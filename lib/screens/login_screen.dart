import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

import '../features/auth/cubit/auth_cubit.dart';
import 'auth/auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo()
                          .animate(controller: _animationController)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: -0.3, end: 0),

                      const SizedBox(height: 60),

                      BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return _buildLoadingCard();
                              } else if (state is AuthSuccess) {
                                return _buildSuccessCard(state.user);
                              } else if (state is AuthFailure) {
                                return _buildErrorCard(state.message);
                              }
                              return _buildLoginCard();
                            },
                          )
                          .animate(controller: _animationController)
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),
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
          children: List.generate(5, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 1.257);
            final size = 120.0 + (index * 40);
            final opacity = 0.05 - (index * 0.008);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (150 + index * 60) * (index.isEven ? 1 : -1) * 0.7,
              top:
                  MediaQuery.of(context).size.height * 0.4 +
                  (80 + index * 50) * (index.isEven ? 1 : -1) * 0.6,
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF6B6B).withValues(alpha: opacity),
                        const Color(
                          0xFF4ECDC4,
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

  Widget _buildLogo() {
    return Column(
      children: [
        GlassmorphicContainer(
          width: 120,
          height: 120,
          borderRadius: 35,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
              const Color(0xFFFFFFFF).withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.3),
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
              ),
            ),
            child: const Icon(IconlyBold.video, color: Colors.white, size: 50),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
          ).createShader(bounds),
          child: const Text(
            'K2B2 Video',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أقوى منصة فيديوهات من كل مكان',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 400,
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text(
              'تسجيل الدخول',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر طريقة تسجيل الدخول المفضلة لديك',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),

            _buildAuthButton(
              icon: IconlyBold.profile,
              label: 'جوجل',
              color: const Color(0xFFDB4437),
              onTap: () => context.read<AuthCubit>().signInWithGoogle(),
            ),

            const SizedBox(height: 16),

            _buildAuthButton(
              icon: IconlyBold.chat,
              label: 'فيسبوك',
              color: const Color(0xFF4267B2),
              onTap: () {
                _showSnackBar('فيسبوك قريباً!');
              },
            ),

            const SizedBox(height: 16),

            _buildAuthButton(
              icon: IconlyBold.message,
              label: 'بريد إلكتروني',
              color: const Color(0xFF4ECDC4),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),

            const SizedBox(height: 14),

            Text(
              'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'جاري تسجيل الدخول...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(String user) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 250,
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
          const Color(0xFF27AE60).withValues(alpha: 0.3),
          const Color(0xFF2ECC71).withValues(alpha: 0.2),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
              ),
            ),
            child: const Icon(
              IconlyBold.tick_square,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'تم بنجاح!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مرحباً $user!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
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
          const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          const Color(0xFFE74C3C).withValues(alpha: 0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFE74C3C)],
                ),
              ),
              child: const Icon(
                IconlyBold.close_square,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                setState(() {}); // Refresh to show login options again
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
                  ),
                ),
                child: const Text(
                  'حاول مرة أخرى',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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

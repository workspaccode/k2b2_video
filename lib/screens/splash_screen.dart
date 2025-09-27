import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    // Navigate to next screen
    if (mounted) {
      // Add navigation logic here
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _progressController.dispose();
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
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
        ),
        child: Stack(children: [_buildAnimatedBackground(), _buildContent()]),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final angle =
                (_backgroundController.value * 2 * 3.14159) + (index * 0.785);
            final size = 80.0 + (index * 30);
            final opacity = 0.05 - (index * 0.006);
            final speed = 0.3 + (index * 0.1);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (150 + index * 40) * (index.isEven ? 1 : -1) * speed,
              top:
                  MediaQuery.of(context).size.height * 0.5 +
                  (100 + index * 60) * (index.isEven ? 1 : -1) * speed,
              child: Transform.rotate(
                angle: angle * (index.isEven ? 1 : -1),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (index.isEven
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF4ECDC4))
                            .withValues(alpha: opacity),
                        (index.isEven
                                ? const Color(0xFF4ECDC4)
                                : const Color(0xFFFF6B6B))
                            .withValues(alpha: opacity * 0.5),
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

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Container
          AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.5 + (_logoController.value * 0.5),
                child: Opacity(
                  opacity: _logoController.value,
                  child: GlassmorphicContainer(
                    width: 140,
                    height: 140,
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
                      child: const Icon(
                        IconlyBold.video,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // App Name
          ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                ).createShader(bounds),
                child: const Text(
                  'K2B2 Video',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Subtitle
          Text(
                'أقوى منصة فيديوهات من كل مكان',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 60),

          // Loading Progress
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Column(
                children: [
                  // Progress Bar
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 200 * _progressController.value,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loading Text
                  Text(
                    'جاري التحميل...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ).animate(delay: 1200.ms).fadeIn(duration: 600.ms),

          const SizedBox(height: 80),

          // Version & Features
          Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureChip('جودة 4K'),
                      const SizedBox(width: 12),
                      _buildFeatureChip('تحميل سريع'),
                      const SizedBox(width: 12),
                      _buildFeatureChip('بدون إعلانات'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
              .animate(delay: 1500.ms)
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

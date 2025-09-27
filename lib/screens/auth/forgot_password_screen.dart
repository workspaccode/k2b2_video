import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

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
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _emailController.dispose();
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
                    const SizedBox(height: 40),

                    // Header with back button
                    _buildHeader()
                        .animate(controller: _animationController)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 60),

                    // Main content
                    _emailSent
                        ? _buildSuccessCard()
                        : _buildForgotPasswordCard(),
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
            final size = 100.0 + (index * 50);
            final opacity = 0.04 - (index * 0.008);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (120 + index * 80) * (index.isEven ? 1 : -1) * 0.8,
              top:
                  MediaQuery.of(context).size.height * 0.3 +
                  (60 + index * 70) * (index.isEven ? 1 : -1) * 0.7,
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
            'استعادة كلمة المرور',
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

  Widget _buildForgotPasswordCard() {
    return GlassmorphicContainer(
          width: double.infinity,
          height: 450,
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
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                    ),
                  ),
                  child: const Icon(
                    IconlyBold.lock,
                    color: Colors.white,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'نسيت كلمة المرور؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Email form
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'البريد الإلكتروني مطلوب';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value!)) {
                        return 'أدخل بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        IconlyBold.message,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF4ECDC4),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFFF6B6B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'إرسال رابط الاستعادة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(controller: _animationController)
        .fadeIn(duration: 800.ms, delay: 200.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSuccessCard() {
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
              const Color(0xFF27AE60).withValues(alpha: 0.3),
              const Color(0xFF2ECC71).withValues(alpha: 0.2),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    ),
                  ),
                  child: const Icon(
                    IconlyBold.tick_square,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'تم الإرسال بنجاح!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني. تحقق من صندوق الوارد والرسائل المرفوضة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                            _emailController.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.8),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('إرسال مرة أخرى'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF45B7D1)],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text(
                            'العودة للدخول',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

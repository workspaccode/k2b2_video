import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconly/iconly.dart';

import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _backgroundController;
  late AnimationController _formController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
              const Color(0xFF1A1A2E).withValues(alpha: 0.9),
              const Color(0xFF16213E).withValues(alpha: 0.9),
              const Color(0xFF0F172A).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedBackground(),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo and title
                    _buildHeader()
                        .animate(controller: _formController)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 60),

                    // Auth form
                    _buildAuthForm()
                        .animate(controller: _formController)
                        .fadeIn(duration: 800.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 30),

                    // Social auth
                    _buildSocialAuth()
                        .animate(controller: _formController)
                        .fadeIn(duration: 800.ms, delay: 400.ms)
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
            final size = 150.0 + (index * 30);
            final opacity = 0.1 - (index * 0.015);

            return Positioned(
              left:
                  MediaQuery.of(context).size.width * 0.5 +
                  (200 + index * 50) *
                      (index.isEven ? 1 : -1) *
                      (index.isOdd ? 1 : 0.5) *
                      (0.5 + 0.5 * (index / 6)),
              top:
                  MediaQuery.of(context).size.height * 0.3 +
                  (100 + index * 40) *
                      (index.isEven ? 1 : -1) *
                      (index.isOdd ? 0.5 : 1) *
                      (0.5 + 0.5 * (index / 6)),
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
    return Column(
      children: [
        // Logo container with glassmorphism
        GlassmorphicContainer(
          width: 100,
          height: 100,
          borderRadius: 30,
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
              const Color(0xFFFFFFFF).withValues(alpha: 0.2),
              const Color(0xFFFFFFFF).withValues(alpha: 0.1),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
              ),
            ),
            child: const Icon(IconlyBold.play, color: Colors.white, size: 40),
          ),
        ),

        const SizedBox(height: 24),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
          ).createShader(bounds),
          child: const Text(
            'K2B2 Video',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _isLogin ? 'Welcome back!' : 'Join us today!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: _isLogin ? 420 : 480,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Toggle buttons
              _buildToggleButtons(),

              const SizedBox(height: 32),

              // Form fields
              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: IconlyBold.profile,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: IconlyBold.message,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: IconlyBold.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? IconlyLight.show : IconlyLight.hide,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Password is required';
                  if (value!.length < 6) {
                    return 'Password must be 6+ characters';
                  }
                  return null;
                },
              ),

              //const SizedBox(height: 8),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: _isLogin
                      ? const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                        )
                      : null,
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: _isLogin ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: !_isLogin
                      ? const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                        )
                      : null,
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: !_isLogin ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isLogin ? 'Sign In' : 'Create Account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialAuth() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: 'assets/icons/google.png',
                label: 'Google',
                onTap: _handleGoogleSignIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSocialButton(
                icon: 'assets/icons/facebook.png',
                label: 'Facebook',
                onTap: _handleFacebookSignIn,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 32,
        borderRadius: 12,
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
            const Icon(IconlyBold.profile, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Update display name
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _nameController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFacebookSignIn() {
    // Facebook sign-in implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook sign-in coming soon!'),
        backgroundColor: Color(0xFF4ECDC4),
      ),
    );
  }
}

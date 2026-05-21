import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_screen.dart';
import 'main.dart';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Dumbbell icon
              Icon(Icons.fitness_center_rounded,
                  color: ivoryWhite, size: 48),
              const SizedBox(height: 16),

              // FORGE wordmark
              Text(
                'FORGE',
                style: GoogleFonts.bebasNeue(
                  color: ivoryWhite,
                  fontSize: 56,
                  letterSpacing: 6,
                ),
              ),

              const SizedBox(height: 48),

              // 3 feature icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureIcon(Icons.track_changes_rounded, 'SMART GOALS'),
                  _buildFeatureIcon(Icons.bolt_rounded, 'CUSTOM SPLITS'),
                  _buildFeatureIcon(Icons.bar_chart_rounded, 'TRACK PROGRESS'),
                ],
              ),

              const Spacer(),

              // START FORGING button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SignupScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                            opacity: animation, child: child);
                      },
                      transitionDuration:
                          const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: ivoryWhite,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'START FORGING',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.black,
                      fontSize: 20,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Already a beast
              GestureDetector(
                onTap: () => _showLoginSheet(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Already a beast? ',
                    style: GoogleFonts.dmSans(
                        color: midGrey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Log In',
                        style: GoogleFonts.dmSans(
                          color: ivoryWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(icon, color: ivoryWhite, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.bebasNeue(
            color: midGrey,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WELCOME BACK',
              style: GoogleFonts.bebasNeue(
                color: ivoryWhite,
                fontSize: 28,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline),
            const SizedBox(height: 12),
            _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true),
            const SizedBox(height: 24),
            GestureDetector(
  onTap: () async {
    if (_isLoggingIn) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoggingIn = true);
    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Login failed',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ivoryWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isLoggingIn
                    ? SizedBox(
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'LOG IN',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bebasNeue(
                          color: Colors.black,
                          fontSize: 20,
                          letterSpacing: 3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.dmSans(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: const Color(0xFFA0A0A0)),
          prefixIcon: Icon(icon, color: const Color(0xFFA0A0A0), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

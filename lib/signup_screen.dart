import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'calibrate_screen.dart';
import 'dart:typed_data';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
  
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);
  Uint8List? _imageBytes;
  XFile? _pickedImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    final bytes = await image.readAsBytes();
    setState(() {
      _pickedImage = image;
      _imageBytes = bytes;
    });
  }
}

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.signup(
      name: name,
      email: email,
      password: password,
    );

    if (result['success']) {
      // Auto login after signup
      final loginResult = await ApiService.login(
        email: email,
        password: password,
      );

      if (loginResult['success']) {
        await ApiService.saveUserInfo(name, email);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const CalibrateScreen()),
);
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = loginResult['message'] ?? 'Login failed after signup';
          _isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _errorMessage = result['message'] ?? 'Signup failed';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'FORGE',
                style: GoogleFonts.bebasNeue(
                  color: ivoryWhite,
                  fontSize: 36,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'Create Your Identity',
                      style: GoogleFonts.bebasNeue(
                        color: ivoryWhite,
                        fontSize: 26,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a gym alias or use your real name',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(color: midGrey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Profile picture
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFF1A1A1A),
                            backgroundImage: _pickedImage != null
                                ? FileImage(File(_pickedImage!.path))
                                : null,
                            child: _pickedImage == null
                                ? Icon(
                                    Icons.camera_alt_outlined,
                                    color: midGrey,
                                    size: 28,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildTextField(
                        controller: _nameController,
                        hint: 'Username / Alias',
                        icon: Icons.person_outline),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    _buildTextField(
                        controller: _confirmController,
                        hint: 'Confirm Password',
                        icon: Icons.lock_outline,
                        obscure: true),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.dmSans(
                            color: Colors.redAccent, fontSize: 13),
                      ),
                    ],

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: _isLoading ? null : _signup,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isLoading ? midGrey : ivoryWhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Text(
                                'FORGE YOUR IDENTITY',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.bebasNeue(
                                  color: Colors.black,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
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

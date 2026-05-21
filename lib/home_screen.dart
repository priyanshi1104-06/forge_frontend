import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'api_service.dart';
import 'main.dart';
import 'log_workout_screen.dart';
import 'ai_screen.dart';
import 'login_screen.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends StatefulWidget {
  final int currentIndex;
  const HomeScreen({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color bgColor = Color(0xFF000000);

  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

   String aliasName = "PRIYANSHI";
  String? profileImageUrl;
  Uint8List? _imageBytes;
bool _isLoading = true;

  final List<String> quotes = [
    "The iron never lies to you.",
    "Your only competition is who you were yesterday.",
    "Strong body, stronger mind.",
    "Excuses burn zero calories.",
    "Don't wish for it. Work for it.",
    "Train insane or remain the same.",
    "SORE TODAY, STRONG TOMORROW",
    "The pain you feel today is the strength you feel tomorrow.",
  ];

  late String currentQuote;

  @override
void initState() {
  super.initState();
  currentQuote = quotes[Random().nextInt(quotes.length)];
  _loadUser();
}

void _loadUser() async {
  final result = await ApiService.getMe();
  if (result['success']) {
    setState(() {
      aliasName = result['data']['name'] ?? 'FORGE';
      _isLoading = false;
    });
  }
  _loadProfileImage();
}

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imgString = prefs.getString('profile_image');
    if (imgString != null && imgString.isNotEmpty) {
      try {
        final bytes = base64Decode(imgString);
        setState(() => _imageBytes = bytes);
      } catch (_) {}
    }
  }

  void _openSettings() {
    final mainScreen = context.findAncestorStateOfType<MainScreenState>();
    mainScreen?.changePage(2);
  }

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Forge Out?',
            style: GoogleFonts.bebasNeue(color: ivoryWhite, fontSize: 20)),
        content: Text('Do you want to forge out from the app?',
            style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('OK',
                style: GoogleFonts.bebasNeue(color: ivoryWhite, fontSize: 14)),
          ),
        ],
      ),
    );

    if (result == true) {
      await ApiService.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String getInitials(String alias) {
    List<String> parts = alias.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return alias.substring(0, min(2, alias.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home_rounded, color: ivoryWhite, size: 28),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF222222),
                        backgroundImage: _imageBytes != null
                            ? MemoryImage(_imageBytes!) as ImageProvider
                            : (profileImageUrl != null ? NetworkImage(profileImageUrl!) : null),
                        child: _imageBytes == null && profileImageUrl == null
                            ? Text(
                                getInitials(aliasName),
                                style: GoogleFonts.dmSans(
                                  color: ivoryWhite,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _showProfileMenu(context),
                        child: Icon(Icons.more_horiz, color: midGrey, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ASK AI button
                    GestureDetector(
                      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AiScreen()),
  );
},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: ivoryWhite, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'ASK AI',
                              style: GoogleFonts.dmSans(
                                color: ivoryWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Greeting + Quote centered
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getGreeting(),
                            style: GoogleFonts.bebasNeue(
                              color: midGrey,
                              fontSize: 28,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            aliasName,
                            style: GoogleFonts.bebasNeue(
                              color: ivoryWhite,
                              fontSize: 52,
                              letterSpacing: 3,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Text(
                              currentQuote.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.bebasNeue(
                                color: ivoryWhite,
                                fontSize: 16,
                                letterSpacing: 2,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cards at bottom
                    _buildActionCard(
  title: 'LOG WORKOUT',
  subtitle: 'Record your session',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogWorkoutScreen()),
    );
  },
),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom nav
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.bebasNeue(
                    color: ivoryWhite,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: midGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ivoryWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: bgColor,
      border: Border(
        top: BorderSide(color: cardBorder, width: 0.5),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(icon: Icons.home_rounded, index: 0),
        _buildNavItem(icon: Icons.fitness_center_rounded, index: 1),
        _buildNavItem(icon: Icons.settings_rounded, index: 2),
      ],
    ),
  );
}

Widget _buildNavItem({required IconData icon, required int index}) {
  final isActive = widget.currentIndex == index;
  return GestureDetector(
    onTap: () {
      if (index == 0) {
        _loadProfileImage();
      }
      final mainScreen = context.findAncestorStateOfType<MainScreenState>();
      mainScreen?.changePage(index);
    },
    child: Icon(
      icon,
      color: isActive ? ivoryWhite : midGrey,
      size: isActive ? 28 : 26,
    ),
  );
}

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuOption(
              Icons.person_outline,
              'Edit Profile',
              () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
            _buildMenuOption(
              Icons.notifications_none_rounded,
              'Notifications',
              () {
                Navigator.pop(context);
                _openSettings();
              },
            ),
            _buildMenuOption(
              Icons.logout_rounded,
              'Log Out',
              () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
      IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: ivoryWhite, size: 22),
      title: Text(
        label,
        style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
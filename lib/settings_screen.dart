import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final int currentIndex;
  const SettingsScreen({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  String aliasName = 'FORGE';
  String realName = 'Real Name';
  String email = 'user@example.com';
  String age = '20';
  String weight = '60';
  String height = '165';
  bool notificationsOn = true;
  String selectedUnit = 'KG';
  String? profileImageUrl;
  Uint8List? _imageBytes;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final meResult = await ApiService.getMe();
    if (meResult['success']) {
      setState(() {
        realName = meResult['data']['name'] ?? 'Real Name';
        email = meResult['data']['email'] ?? 'user@example.com';
      });
    }

    final profileResult = await ApiService.getProfile();
    if (profileResult['success']) {
      final data = profileResult['data'];
      setState(() {
        age = data['age']?.toString() ?? '20';
        weight = data['weight_kg']?.toString() ?? '60';
        height = data['height_cm']?.toString() ?? '165';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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

  Future<void> _saveProfileImage(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = base64Encode(bytes);
    await prefs.setString('profile_image', encoded);
  }

  Future<void> _removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image');
    setState(() {
      _imageBytes = null;
      _pickedImage = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImage = image;
          _imageBytes = bytes;
        });
        await _saveProfileImage(bytes);
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            if (_imageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editField(String label, String current, Function(String) onSave) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cardBorder),
        ),
        title: Text(
          'EDIT ${label.toUpperCase()}',
          style: GoogleFonts.bebasNeue(color: ivoryWhite, fontSize: 20, letterSpacing: 2),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.dmSans(color: ivoryWhite),
          cursorColor: ivoryWhite,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.dmSans(color: midGrey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cardBorder)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 16, letterSpacing: 1.5)),
          ),
          TextButton(
            onPressed: () async {
              onSave(controller.text);
              Navigator.pop(context);
              // Save to backend
              await ApiService.updateProfile({
                'age': int.tryParse(age) ?? 0,
                'weight_kg': double.tryParse(weight) ?? 0,
                'height_cm': double.tryParse(height) ?? 0,
              });
            },
            child: Text('SAVE',
                style: GoogleFonts.bebasNeue(color: ivoryWhite, fontSize: 16, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  String getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('SETTINGS',
                      style: GoogleFonts.bebasNeue(
                          color: ivoryWhite, fontSize: 28, letterSpacing: 3)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Profile card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: const Color(0xFF222222),
                                    child: _imageBytes != null
                                        ? CircleAvatar(
                                            radius: 36,
                                            backgroundColor: const Color(0xFF222222),
                                            backgroundImage: MemoryImage(_imageBytes!),
                                          )
                                        : Text(getInitials(aliasName),
                                            style: GoogleFonts.bebasNeue(
                                                color: ivoryWhite, fontSize: 22)),
                                  ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _showImageOptions,
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: const BoxDecoration(
                                                  color: Colors.white, shape: BoxShape.circle),
                                              child: const Icon(Icons.add,
                                                  color: Colors.black, size: 14),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(aliasName,
                                            style: GoogleFonts.bebasNeue(
                                                color: ivoryWhite,
                                                fontSize: 22,
                                                letterSpacing: 2)),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _editField('Alias Name', aliasName,
                                              (val) => setState(() => aliasName = val)),
                                          child: Icon(Icons.edit, color: midGrey, size: 14),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(realName,
                                            style: GoogleFonts.dmSans(
                                                color: midGrey, fontSize: 13)),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _editField('Real Name', realName,
                                              (val) => setState(() => realName = val)),
                                          child: Icon(Icons.edit, color: cardBorder, size: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _sectionLabel('PROFILE'),
                        const SizedBox(height: 10),

                        _buildEditRow('Age', '$age yrs',
                            () => _editField('Age', age, (val) => setState(() => age = val))),
                        _buildEditRow('Weight', '$weight kg',
                            () => _editField('Weight', weight, (val) => setState(() => weight = val))),
                        _buildEditRow('Height', '$height cm',
                            () => _editField('Height', height, (val) => setState(() => height = val))),

                        const SizedBox(height: 24),
                        _sectionLabel('PREFERENCES'),
                        const SizedBox(height: 10),

                        // Units
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Units',
                                  style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
                              Row(
                                children: ['KG', 'LBS'].map((unit) {
                                  final isSelected = selectedUnit == unit;
                                  return GestureDetector(
                                    onTap: () => setState(() => selectedUnit = unit),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? ivoryWhite : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: isSelected ? ivoryWhite : cardBorder),
                                      ),
                                      child: Text(unit,
                                          style: GoogleFonts.bebasNeue(
                                              color: isSelected ? Colors.black : midGrey,
                                              fontSize: 14,
                                              letterSpacing: 1)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Notifications
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Notifications',
                                  style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
                              Switch(
                                value: notificationsOn,
                                onChanged: (val) => setState(() => notificationsOn = val),
                                activeColor: ivoryWhite,
                                activeTrackColor: const Color(0xFF444444),
                                inactiveThumbColor: midGrey,
                                inactiveTrackColor: cardBorder,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _sectionLabel('ACCOUNT'),
                        const SizedBox(height: 10),

                        _buildEditRow('Email', email,
                            () => _editField('Email', email,
                                (val) => setState(() => email = val))),
                        _buildEditRow('Password', '••••••••', () {}),

                        const SizedBox(height: 24),
                        _sectionLabel('ABOUT'),
                        const SizedBox(height: 10),

                        _buildStaticRow('App Version', '1.0.0'),
                        _buildStaticRow('Privacy Policy', ''),
                        _buildStaticRow('Terms of Service', ''),

                        const SizedBox(height: 24),

                        // Logout
                        GestureDetector(
                          onTap: () async {
                            await ApiService.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.logout,
                                    color: Colors.redAccent, size: 20),
                                const SizedBox(width: 12),
                                Text('Log Out',
                                    style: GoogleFonts.dmSans(
                                        color: Colors.redAccent,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 13, letterSpacing: 2));
  }

  Widget _buildEditRow(String label, String value, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
          Row(
            children: [
              Text(value, style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTap,
                child: Icon(Icons.edit, color: midGrey, size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
          if (value.isNotEmpty)
            Text(value, style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
          if (value.isEmpty)
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 12),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: cardBorder, width: 0.5)),
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
        final mainScreen = context.findAncestorStateOfType<MainScreenState>();
        mainScreen?.changePage(index);
      },
      child: Icon(icon,
          color: isActive ? ivoryWhite : midGrey, size: isActive ? 28 : 26),
    );
  }
}
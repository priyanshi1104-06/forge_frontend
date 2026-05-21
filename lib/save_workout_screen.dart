import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'workout_complete_screen.dart';
import 'main.dart';
import 'workout_complete_screen.dart';

class SaveWorkoutScreen extends StatefulWidget {
  final String duration;
  final double volume;
  final int sets;
  final String date;
  final String notes;
  final int elapsedSeconds;

  const SaveWorkoutScreen({
    Key? key,
    required this.duration,
    required this.volume,
    required this.sets,
    required this.date,
    required this.notes,
    required this.elapsedSeconds,
  }) : super(key: key);

  @override
  State<SaveWorkoutScreen> createState() => _SaveWorkoutScreenState();
}

class _SaveWorkoutScreenState extends State<SaveWorkoutScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  XFile? _photo;
  bool _isLoading = false;

  String get _formattedDateTime {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$min $ampm';
  }

  void _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _photo = image);
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cardBorder),
        ),
        title: Text('DISCARD WORKOUT?',
            style: GoogleFonts.bebasNeue(color: ivoryWhite, fontSize: 22, letterSpacing: 2)),
        content: Text('Your workout will not be saved.',
            style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 16, letterSpacing: 1.5)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
            child: Text('DISCARD',
                style: GoogleFonts.bebasNeue(color: Colors.redAccent, fontSize: 16, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() async {
    setState(() => _isLoading = true);

    final title = _titleController.text.isEmpty ? 'My Workout' : _titleController.text;
    final fullNotes = '$title | ${widget.notes}${_descController.text.isNotEmpty ? ' | ${_descController.text}' : ''}';

    final result = await ApiService.createWorkout(
      date: widget.date,
      notes: fullNotes,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompleteScreen(
            duration: widget.duration,
            volume: widget.volume,
            sets: widget.sets,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save', style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ));
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: ivoryWhite, size: 22),
                  ),
                  Text('Save Workout',
                      style: GoogleFonts.dmSans(
                          color: ivoryWhite, fontSize: 16, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: _isLoading ? null : _saveWorkout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: ivoryWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 16, width: 16,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : Text('Save',
                              style: GoogleFonts.bebasNeue(
                                  color: Colors.black, fontSize: 18, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Workout title
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 22, fontWeight: FontWeight.w600),
                    cursorColor: ivoryWhite,
                    decoration: InputDecoration(
                      hintText: 'Workout title',
                      hintStyle: GoogleFonts.dmSans(color: midGrey, fontSize: 22, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats
                  Row(
                    children: [
                      _buildStatItem('Duration', widget.duration),
                      const SizedBox(width: 24),
                      _buildStatItem('Volume', '${widget.volume.toStringAsFixed(0)} kg'),
                      const SizedBox(width: 24),
                      _buildStatItem('Sets', '${widget.sets}'),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: cardBorder, height: 1),

                  // When
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Text('When', style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
                        const SizedBox(width: 16),
                        Text(_formattedDateTime,
                            style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14)),
                      ],
                    ),
                  ),
                  Divider(color: cardBorder, height: 1),

                  // Add photo
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          _photo != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _photo!.path,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: cardBorder, style: BorderStyle.solid),
                                  ),
                                  child: Icon(Icons.add_photo_alternate_outlined,
                                      color: midGrey, size: 28),
                                ),
                          const SizedBox(width: 16),
                          Text('Add a photo / video',
                              style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: cardBorder, height: 1),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description',
                            style: GoogleFonts.dmSans(color: midGrey, fontSize: 13)),
                        TextField(
                          controller: _descController,
                          style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 14),
                          cursorColor: ivoryWhite,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'How did your workout go? Leave some notes here...',
                            hintStyle: GoogleFonts.dmSans(color: midGrey, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: cardBorder, height: 1),

                  const SizedBox(height: 32),

                  // Discard
                  GestureDetector(
                    onTap: _showDiscardDialog,
                    child: Center(
                      child: Text('Discard Workout',
                          style: GoogleFonts.dmSans(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                color: ivoryWhite, fontSize: 18, fontWeight: FontWeight.w600)),
        Text(label, style: GoogleFonts.dmSans(color: midGrey, fontSize: 12)),
      ],
    );
  }
}
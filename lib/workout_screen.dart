import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'api_service.dart';
import 'log_workout_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final int currentIndex;
  const WorkoutScreen({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  bool _showForgeLabel = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() async {
    final result = await ApiService.getWorkouts();
    if (result['success']) {
      setState(() {
        workouts = (result['data'] as List)
    .map((e) => Map<String, dynamic>.from(e))
    .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cardBorder),
        ),
        title: Text('FORGE OUT?',
            style: GoogleFonts.bebasNeue(
                color: ivoryWhite, fontSize: 22, letterSpacing: 2)),
        content: Text('Do you want to forge out this workout?',
            style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: GoogleFonts.bebasNeue(
                    color: midGrey, fontSize: 16, letterSpacing: 1.5)),
          ),
          TextButton(
            onPressed: () async {
              final id = workouts[index]['id'];
              await ApiService.deleteWorkout(id);
              setState(() => workouts.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('OK',
                style: GoogleFonts.bebasNeue(
                    color: ivoryWhite, fontSize: 16, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showWorkoutOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              title: Text('Delete Workout',
                  style: GoogleFonts.dmSans(color: Colors.redAccent, fontSize: 15)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Parse notes string into workout name and exercises
  Map<String, dynamic> _parseWorkout(Map<String, dynamic> workout) {
    final notes = workout['notes'] ?? '';
    final parts = notes.split(' | ');
    final name = parts.isNotEmpty ? parts[0] : 'Workout';
    final List<String> exercises = parts.length > 1
    ? List<String>.from(parts.sublist(1).map((e) => e.toString().trim()).where((e) => e.toString().isNotEmpty))
    : <String>[];
return {'name': name, 'exercises': exercises, 'date': workout['date'].toString()};
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
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() => _showForgeLabel = true);
                      await Future.delayed(const Duration(seconds: 2));
                      setState(() => _showForgeLabel = false);
                    },
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _showForgeLabel = true),
                      onExit: (_) => setState(() => _showForgeLabel = false),
                      child: Row(
                        children: [
                          Text('F',
                              style: GoogleFonts.bebasNeue(
                                  color: ivoryWhite,
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic)),
                          if (_showForgeLabel) ...[
                            const SizedBox(width: 4),
                            Text('ORGE',
                                style: GoogleFonts.bebasNeue(
                                    color: midGrey,
                                    fontSize: 16,
                                    letterSpacing: 3)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogWorkoutScreen()),
                      ).then((_) => _loadWorkouts());
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ivoryWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            // Heading
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('PAST WORKOUTS',
                  style: GoogleFonts.bebasNeue(
                      color: ivoryWhite, fontSize: 28, letterSpacing: 3)),
            ),

            // Workout list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : workouts.isEmpty
                      ? Center(
                          child: Text('NO PAST RECORDS',
                              style: GoogleFonts.bebasNeue(
                                  color: midGrey,
                                  fontSize: 20,
                                  letterSpacing: 2)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: workouts.length,
                          itemBuilder: (context, index) {
                            final parsed = _parseWorkout(workouts[index]);
                            final name = parsed['name'] as String;
                            final exercises = List<String>.from(parsed['exercises'] as List);
                            final date = parsed['date'] as String;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(name,
                                            style: GoogleFonts.bebasNeue(
                                                color: ivoryWhite,
                                                fontSize: 20,
                                                letterSpacing: 1.5)),
                                      ),
                                      Row(
                                        children: [
                                          Text(date,
                                              style: GoogleFonts.dmSans(
                                                  color: midGrey,
                                                  fontSize: 11)),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () =>
                                                _showWorkoutOptions(index),
                                            child: Icon(Icons.more_horiz,
                                                color: midGrey, size: 22),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(
                                      color: Color(0xFF222222), height: 1),
                                  const SizedBox(height: 10),
                                  ...exercises.map((ex) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            const Text('🏋️',
                                                style:
                                                    TextStyle(fontSize: 13)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(ex,
                                                  style: GoogleFonts.dmSans(
                                                      color: midGrey,
                                                      fontSize: 13)),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            _buildBottomNav(),
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
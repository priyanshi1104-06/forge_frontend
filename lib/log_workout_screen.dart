import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'save_workout_screen.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);
  static const Color doneGreen = Color(0xFF4CAF50);

  final List<Map<String, dynamic>> _exercises = [];

  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _duration = '0s';
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds = _stopwatch.elapsed.inSeconds;
        final elapsed = _stopwatch.elapsed;
        if (elapsed.inHours > 0) {
          _duration = '${elapsed.inHours}h ${elapsed.inMinutes.remainder(60)}m';
        } else if (elapsed.inMinutes > 0) {
          _duration = '${elapsed.inMinutes}m ${elapsed.inSeconds.remainder(60)}s';
        } else {
          _duration = '${elapsed.inSeconds}s';
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  int get totalSets {
    int count = 0;
    for (var ex in _exercises) {
      for (var set in (ex['sets'] as List)) {
        if (set['done'] == true) count++;
      }
    }
    return count;
  }

  double get totalVolume {
    double vol = 0;
    for (var ex in _exercises) {
      for (var set in (ex['sets'] as List)) {
        if (set['done'] == true) {
          final kg = double.tryParse(set['kg'].toString()) ?? 0;
          final reps = double.tryParse(set['reps'].toString()) ?? 0;
          vol += kg * reps;
        }
      }
    }
    return vol;
  }

  void _showAddExerciseSheet() {
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD EXERCISE',
                style: GoogleFonts.bebasNeue(
                    color: ivoryWhite, fontSize: 24, letterSpacing: 2)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cardBorder),
              ),
              child: TextField(
                controller: nameController,
                autofocus: true,
                style: GoogleFonts.dmSans(color: ivoryWhite),
                cursorColor: ivoryWhite,
                decoration: InputDecoration(
                  hintText: 'Exercise name',
                  hintStyle: GoogleFonts.dmSans(color: midGrey),
                  prefixIcon: Icon(Icons.fitness_center, color: midGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (nameController.text.isEmpty) return;
                setState(() {
                  _exercises.add({
                    'name': nameController.text,
                    'sets': <Map<String, dynamic>>[
                      {'kg': '', 'reps': '', 'done': false}
                    ],
                  });
                });
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ivoryWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('ADD',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                        color: Colors.black, fontSize: 20, letterSpacing: 3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: cardBorder),
        ),
        title: Text('FINISH WORKOUT?',
            style: GoogleFonts.bebasNeue(
                color: Colors.white, fontSize: 22, letterSpacing: 2)),
        content: Text('Are you sure you want to terminate the workout?',
            style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: GoogleFonts.bebasNeue(
                    color: midGrey, fontSize: 16, letterSpacing: 1.5)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              final date =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
              final notes = _exercises.map((ex) {
                final sets = (ex['sets'] as List)
                    .where((s) => s['done'] == true)
                    .map((s) => '${s['kg']}kg x ${s['reps']} reps')
                    .join(', ');
                return '${ex['name']}: $sets';
              }).join(' | ');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SaveWorkoutScreen(
                    duration: _duration,
                    volume: totalVolume,
                    sets: totalSets,
                    date: date,
                    notes: notes,
                    elapsedSeconds: _elapsedSeconds,
                  ),
                ),
              );
            },
            child: Text('OK',
                style: GoogleFonts.bebasNeue(
                    color: Colors.white, fontSize: 16, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
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
                    child: Row(
                      children: [
                        Icon(Icons.keyboard_arrow_down, color: ivoryWhite, size: 28),
                        const SizedBox(width: 6),
                        Text('Log Workout',
                            style: GoogleFonts.dmSans(
                                color: ivoryWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFinishDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: ivoryWhite,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Finish',
                          style: GoogleFonts.bebasNeue(
                              color: Colors.black, fontSize: 18, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),

            // Stats bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(color: cardBorder, width: 0.5),
                  bottom: BorderSide(color: cardBorder, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('Duration', _duration),
                  Container(height: 30, width: 0.5, color: cardBorder),
                  _buildStat('Volume', '${totalVolume.toStringAsFixed(0)} kg'),
                  Container(height: 30, width: 0.5, color: cardBorder),
                  _buildStat('Sets', '$totalSets'),
                ],
              ),
            ),

            // Exercise list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._exercises.asMap().entries.map((entry) {
                    final exIndex = entry.key;
                    final ex = entry.value;
                    final sets = ex['sets'] as List<Map<String, dynamic>>;

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
                          Text(ex['name'],
                              style: GoogleFonts.bebasNeue(
                                  color: ivoryWhite, fontSize: 20, letterSpacing: 1.5)),
                          const SizedBox(height: 12),

                          // Headers
                          Row(
                            children: [
                              SizedBox(width: 40, child: Text('SET', style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 13, letterSpacing: 1))),
                              SizedBox(width: 90, child: Text('KG', style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 13, letterSpacing: 1))),
                              SizedBox(width: 90, child: Text('REPS', style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 13, letterSpacing: 1))),
                              const Spacer(),
                              SizedBox(width: 36, child: Text('✓', style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Sets
                          ...sets.asMap().entries.map((setEntry) {
                            final setIndex = setEntry.key;
                            final set = setEntry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text('${setIndex + 1}',
                                        style: GoogleFonts.bebasNeue(color: midGrey, fontSize: 18)),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 16),
                                      cursorColor: ivoryWhite,
                                      onChanged: (val) => setState(() => set['kg'] = val),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: GoogleFonts.dmSans(color: midGrey, fontSize: 16),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.dmSans(color: ivoryWhite, fontSize: 16),
                                      cursorColor: ivoryWhite,
                                      onChanged: (val) => setState(() => set['reps'] = val),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: GoogleFonts.dmSans(color: midGrey, fontSize: 16),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() => set['done'] = !(set['done'] as bool)),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: set['done'] == true
                                            ? doneGreen
                                            : const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: set['done'] == true ? Colors.white : midGrey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 8),

                          // Add Set
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                sets.add({'kg': '', 'reps': '', 'done': false});
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cardBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: midGrey, size: 16),
                                  const SizedBox(width: 6),
                                  Text('Add Set',
                                      style: GoogleFonts.dmSans(color: midGrey, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Add Exercise
                  GestureDetector(
                    onTap: _showAddExerciseSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: ivoryWhite, size: 20),
                          const SizedBox(width: 8),
                          Text('Add Exercise',
                              style: GoogleFonts.bebasNeue(
                                  color: ivoryWhite, fontSize: 18, letterSpacing: 1.5)),
                        ],
                      ),
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

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1)),
        Text(label, style: GoogleFonts.dmSans(color: midGrey, fontSize: 11)),
      ],
    );
  }
}
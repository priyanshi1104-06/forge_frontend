import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'api_service.dart';

class CalibrateScreen extends StatefulWidget {
  const CalibrateScreen({Key? key}) : super(key: key);

  @override
  State<CalibrateScreen> createState() => _CalibrateScreenState();
}

class _CalibrateScreenState extends State<CalibrateScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedPhysique;
  String? _selectedExperience;

  final List<Map<String, String>> _physiques = [
    {'title': 'Bodybuilder', 'subtitle': 'Maximum muscle mass'},
    {'title': 'Lean', 'subtitle': 'Shredded, low body fat'},
    {'title': 'Athletic', 'subtitle': 'Balanced performance'},
    {'title': 'Fat Loss', 'subtitle': 'Shed extra weight'},
  ];

  final List<Map<String, String>> _experiences = [
    {'title': 'Beginner', 'subtitle': '< 1 YEAR'},
    {'title': 'Intermediate', 'subtitle': '1-3 YEARS'},
    {'title': 'Advanced', 'subtitle': '3+ YEARS'},
  ];

  void _initialize() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter height and weight',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedPhysique == null || _selectedExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your physique goal and experience',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height == 0 || weight == 0) return;

    final bmi = weight / ((height / 100) * (height / 100));
    final bmiRounded = bmi.toStringAsFixed(1);

    String bmiCategory;
    if (bmi < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi < 25) {
      bmiCategory = 'Normal';
    } else if (bmi < 30) {
      bmiCategory = 'Overweight';
    } else {
      bmiCategory = 'Obese';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cardBorder),
        ),
        title: Text(
          'YOUR VIRTUAL BMI',
          style: GoogleFonts.bebasNeue(
            color: ivoryWhite,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bmiRounded,
              style: GoogleFonts.bebasNeue(
                color: ivoryWhite,
                fontSize: 56,
                letterSpacing: 2,
              ),
            ),
            Text(
              bmiCategory.toUpperCase(),
              style: GoogleFonts.bebasNeue(
                color: midGrey,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Protocol initialized. Time to forge.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: midGrey,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
  onPressed: () async {
  await ApiService.setCalibrated();
  await ApiService.updateProfile({
    'height_cm': double.tryParse(_heightController.text) ?? 0,
    'weight_kg': double.tryParse(_weightController.text) ?? 0,
  });
  Navigator.pop(context);
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const MainScreen()),
  );
},
  child: Text(
    'LETS GO',
    style: GoogleFonts.bebasNeue(
      color: ivoryWhite,
      fontSize: 18,
      letterSpacing: 2,
    ),
  ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Heading
              Center(
                child: Text(
                  'CALIBRATE YOUR PROTOCOL',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    color: ivoryWhite,
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'We need your stats to generate your virtual BMI and ideal workout splits.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: midGrey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Height + Weight
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.straighten, color: ivoryWhite, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'HEIGHT',
                                style: GoogleFonts.bebasNeue(
                                  color: ivoryWhite,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.dmSans(
                                        color: ivoryWhite, fontSize: 20),
                                    cursorColor: ivoryWhite,
                                    decoration: InputDecoration(
                                      hintText: '175',
                                      hintStyle: GoogleFonts.dmSans(
                                          color: midGrey, fontSize: 20),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Text('cm',
                                    style: GoogleFonts.dmSans(
                                        color: midGrey, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.monitor_weight_outlined,
                                  color: ivoryWhite, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'WEIGHT',
                                style: GoogleFonts.bebasNeue(
                                  color: ivoryWhite,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.dmSans(
                                        color: ivoryWhite, fontSize: 20),
                                    cursorColor: ivoryWhite,
                                    decoration: InputDecoration(
                                      hintText: '70',
                                      hintStyle: GoogleFonts.dmSans(
                                          color: midGrey, fontSize: 20),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Text('kg',
                                    style: GoogleFonts.dmSans(
                                        color: midGrey, fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Target Physique
              Row(
                children: [
                  Icon(Icons.track_changes, color: ivoryWhite, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'TARGET PHYSIQUE',
                    style: GoogleFonts.bebasNeue(
                      color: ivoryWhite,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: _physiques.map((physique) {
                  final isSelected = _selectedPhysique == physique['title'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPhysique = physique['title']),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? ivoryWhite : cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            physique['title']!,
                            style: GoogleFonts.bebasNeue(
                              color: isSelected ? ivoryWhite : midGrey,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            physique['subtitle']!,
                            style: GoogleFonts.dmSans(
                              color: midGrey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Experience
              Row(
                children: [
                  Icon(Icons.bolt, color: ivoryWhite, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'EXPERIENCE',
                    style: GoogleFonts.bebasNeue(
                      color: ivoryWhite,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: _experiences.map((exp) {
                  final isSelected = _selectedExperience == exp['title'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedExperience = exp['title']),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: exp == _experiences.last ? 0 : 10,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? ivoryWhite : cardBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              exp['title']!,
                              style: GoogleFonts.bebasNeue(
                                color: isSelected ? ivoryWhite : midGrey,
                                fontSize: 15,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              exp['subtitle']!,
                              style: GoogleFonts.dmSans(
                                color: midGrey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Initialize button
              GestureDetector(
                onTap: _initialize,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: ivoryWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'INITIALIZE PROTOCOL',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.black,
                      fontSize: 20,
                      letterSpacing: 3,
                    ),
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
}
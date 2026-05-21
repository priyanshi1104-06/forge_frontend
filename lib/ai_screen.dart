import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({Key? key}) : super(key: key);

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);

  final TextEditingController _goalController = TextEditingController();
  bool _includeDiet = true;
  bool _includeWorkout = true;
  bool _isLoading = false;
  String? _result;

  final List<String> _quickGoals = [
    'Build muscle mass',
    'Lose fat',
    'Increase strength',
    'Improve endurance',
    'Stay athletic',
  ];

  void _getRecommendation() async {
    if (_goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter your goal first',
            style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await ApiService.getAIRecommendation(
      goal: _goalController.text,
      includeDiet: _includeDiet,
      includeWorkout: _includeWorkout,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _result = result['data']['content'];
      } else {
        _result = 'Failed to get recommendation. Try again.';
      }
    });
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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios, color: ivoryWhite, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('ASK AI',
                      style: GoogleFonts.bebasNeue(
                          color: ivoryWhite, fontSize: 28, letterSpacing: 3)),
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, color: midGrey, size: 18),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal input
                    Text('WHAT IS YOUR GOAL?',
                        style: GoogleFonts.bebasNeue(
                            color: midGrey, fontSize: 13, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorder),
                      ),
                      child: TextField(
                        controller: _goalController,
                        style: GoogleFonts.dmSans(color: ivoryWhite),
                        cursorColor: ivoryWhite,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Build muscle and lose fat',
                          hintStyle: GoogleFonts.dmSans(color: midGrey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick goals
                    Text('QUICK SELECT',
                        style: GoogleFonts.bebasNeue(
                            color: midGrey, fontSize: 13, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickGoals.map((goal) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _goalController.text = goal),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _goalController.text == goal
                                  ? ivoryWhite
                                  : cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Text(goal,
                                style: GoogleFonts.dmSans(
                                  color: _goalController.text == goal
                                      ? Colors.black
                                      : midGrey,
                                  fontSize: 12,
                                )),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Toggles
                    Text('INCLUDE IN PLAN',
                        style: GoogleFonts.bebasNeue(
                            color: midGrey, fontSize: 13, letterSpacing: 2)),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Workout Plan',
                                  style: GoogleFonts.dmSans(
                                      color: ivoryWhite, fontSize: 14)),
                              Switch(
                                value: _includeWorkout,
                                onChanged: (val) =>
                                    setState(() => _includeWorkout = val),
                                activeColor: ivoryWhite,
                                activeTrackColor: const Color(0xFF444444),
                                inactiveThumbColor: midGrey,
                                inactiveTrackColor: cardBorder,
                              ),
                            ],
                          ),
                          Divider(color: cardBorder, height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Diet Plan',
                                  style: GoogleFonts.dmSans(
                                      color: ivoryWhite, fontSize: 14)),
                              Switch(
                                value: _includeDiet,
                                onChanged: (val) =>
                                    setState(() => _includeDiet = val),
                                activeColor: ivoryWhite,
                                activeTrackColor: const Color(0xFF444444),
                                inactiveThumbColor: midGrey,
                                inactiveTrackColor: cardBorder,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Generate button
                    GestureDetector(
                      onTap: _isLoading ? null : _getRecommendation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isLoading ? midGrey : ivoryWhite,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.black, strokeWidth: 2),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome,
                                      color: Colors.black, size: 18),
                                  const SizedBox(width: 8),
                                  Text('GENERATE PLAN',
                                      style: GoogleFonts.bebasNeue(
                                          color: Colors.black,
                                          fontSize: 20,
                                          letterSpacing: 2)),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Result
                    if (_result != null) ...[
                      Text('YOUR PLAN',
                          style: GoogleFonts.bebasNeue(
                              color: midGrey, fontSize: 13, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Text(
                          _result!,
                          style: GoogleFonts.dmSans(
                              color: ivoryWhite,
                              fontSize: 13,
                              height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
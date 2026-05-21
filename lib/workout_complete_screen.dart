import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'api_service.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final String duration;
  final double volume;
  final int sets;

  const WorkoutCompleteScreen({
    Key? key,
    required this.duration,
    required this.volume,
    required this.sets,
  }) : super(key: key);

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  static const Color bgColor = Color(0xFF000000);
  static const Color ivoryWhite = Color(0xFFFFFFFF);
  static const Color midGrey = Color(0xFFA0A0A0);
  static const Color cardColor = Color(0xFF111111);

  late ConfettiController _confettiController;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _comparisonText = 'Keep forging! 💪';

  @override
void initState() {
  super.initState();
  _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  _confettiController.play();
  _loadComparison();
}

void _loadComparison() async {
  final result = await ApiService.getProgressSummary();
  if (result['success']) {
    final comparison = result['data']['comparison'];
    if (comparison != null) {
      setState(() {
        _comparisonText = comparison['text'] ?? 'Keep forging! 💪';
      });
    }
  }
}

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String get _shareText =>
      'Just crushed a workout! 💪\n⏱ ${widget.duration}\n🏋️ ${widget.volume.toStringAsFixed(0)} kg volume\n✅ ${widget.sets} sets\n\n#FORGE #fitness #gym';

  void _shareToInstagram() async {
    final uri = Uri.parse('instagram://app');
    if (await canLaunchUrl(uri)) {
      await Share.share(_shareText);
    } else {
      await Share.share(_shareText);
    }
  }

  void _shareToTwitter() async {
    final text = Uri.encodeComponent(_shareText);
    final uri = Uri.parse('https://twitter.com/intent/tweet?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyText() async {
    await Clipboard.setData(ClipboardData(text: _shareText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard',
          style: GoogleFonts.dmSans(color: Colors.white)),
      backgroundColor: const Color(0xFF1A1A1A),
      duration: const Duration(seconds: 2),
    ));
  }

  void _shareMore() async {
    await Share.share(_shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red, Colors.green, Colors.blue,
                  Colors.yellow, Colors.white,
                ],
                numberOfParticles: 30,
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 48),

                // Good job
                Text('Good job!',
                    style: GoogleFonts.bebasNeue(
                        color: ivoryWhite, fontSize: 36, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('Workout complete',
                    style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),

                const SizedBox(height: 32),

                // Stat cards (swipeable)
                SizedBox(
                  height: 220,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildStatCard(),
                      _buildVolumeCard(),
                    ],
                  ),
                ),

                // Page indicator
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? ivoryWhite : midGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),

                const SizedBox(height: 24),

                // Share text
                Text('Share your workout',
                    style: GoogleFonts.dmSans(color: midGrey, fontSize: 13)),
                const SizedBox(height: 16),

                // Share options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption(
                          icon: Icons.camera_alt,
                          label: 'Stories',
                          onTap: _shareToInstagram),
                      _buildShareOption(
                          icon: Icons.share,
                          label: 'More',
                          onTap: _shareMore),
                      _buildShareOption(
                          icon: Icons.link,
                          label: 'Copy Text',
                          onTap: _copyText),
                      _buildShareOption(
                          icon: Icons.close,
                          label: 'Twitter',
                          onTap: _shareToTwitter),
                    ],
                  ),
                ),

                const Spacer(),

                // Done button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: ivoryWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Done',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.bebasNeue(
                              color: Colors.black, fontSize: 22, letterSpacing: 2)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCardStat(widget.duration, 'Duration'),
          const SizedBox(height: 16),
          _buildCardStat('${widget.volume.toStringAsFixed(0)} kg', 'Volume'),
          const SizedBox(height: 16),
          _buildCardStat('${widget.sets}', 'Sets'),
        ],
      ),
    );
  }

  Widget _buildVolumeCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('You lifted a total of',
            style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
        const SizedBox(height: 8),
        Text('${widget.volume.toStringAsFixed(0)} kg',
            style: GoogleFonts.bebasNeue(
                color: ivoryWhite, fontSize: 48, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(_comparisonText,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
      ],
    ),
  );
}

  Widget _buildCardStat(String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(color: midGrey, fontSize: 14)),
        Text(value,
            style: GoogleFonts.bebasNeue(
                color: ivoryWhite, fontSize: 22, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ivoryWhite, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.dmSans(color: midGrey, fontSize: 11)),
        ],
      ),
    );
  }
}
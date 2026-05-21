import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workout_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';

void main() {
  runApp(const ForgeApp());
}

class ForgeApp extends StatelessWidget {
  const ForgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FORGE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      builder: (context, child) {
        return Container(
          color: Colors.black,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child!,
            ),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  void changePage(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(currentIndex: currentIndex),
          WorkoutScreen(currentIndex: currentIndex),
          SettingsScreen(currentIndex: currentIndex),
        ],
      ),
    );
  }
}
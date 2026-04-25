import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'theme.dart';

void main() {
  runApp(const AlertNestApp());
}

class AlertNestApp extends StatelessWidget {
  const AlertNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertNest',
      debugShowCheckedModeBanner: false,
      theme: buildAlertNestTheme(),
      home: const LandingScreen(),
    );
  }
}

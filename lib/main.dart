import 'package:flutter/material.dart';
import 'package:pawpal/views/splashscreen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 177, 177, 177)
      ),
      home: SplashScreen()
    );
  }
}

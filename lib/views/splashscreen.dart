import 'package:flutter/material.dart';
import 'package:pawpal/views/homescreen.dart';
import 'package:pawpal/views/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen(user: null,)),
      );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', scale: 3),
            const SizedBox(height: 37),
            const CircularProgressIndicator(color: Color.fromARGB(255, 0, 0, 0)),
          ])
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pawpal/views/loginscreen.dart';
import 'package:pawpal/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 177, 177, 177),
        title: const Text('PawPal', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Color.fromARGB(255, 255, 235, 227),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${widget.user?.userName ?? 'User'}!'),
            SizedBox(height: 20),
            Text('User ID: ${widget.user?.userId ?? 'Not provided'}'),
            SizedBox(height: 20),
            Text('Email: ${widget.user?.userEmail ?? 'Not provided'}'),
            SizedBox(height: 20),
            Text('Phone: ${widget.user?.userPhone ?? 'Not provided'}'),
            SizedBox(height: 20),
            Text('Registered on: ${widget.user?.userRegDate ?? 'Not provided'}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signOut();
              }, 
              child: Text('Sign Out')),
          ],
        ),
      ),
    );
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LogInScreen())
    );
  }
}
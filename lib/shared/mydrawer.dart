import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/views/homescreen.dart';
import 'package:pawpal/views/loginscreen.dart';
import 'package:pawpal/views/mypetsscreen.dart';
import 'package:pawpal/views/profilescreen.dart';
import 'package:pawpal/views/mydonationscreen.dart';

class MyDrawer extends StatefulWidget {
  final User user;
  const MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.userName.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(widget.user.userEmail.toString()),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              backgroundColor: Colors.white,
            ),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 177, 177, 177),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Public Listing'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (content) => HomeScreen(user: widget.user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('My Pets'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (content) => MyPetsScreen(user: widget.user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('My Donations'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (content) => MyDonationsScreen(user: widget.user)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (content) => ProfileScreen(user: widget.user)));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (content) => const LogInScreen()));
            },
          ),
        ],
      ),
    );
  }
}
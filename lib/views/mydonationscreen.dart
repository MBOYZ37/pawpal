import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';

class MyDonationsScreen extends StatefulWidget {
  final User user;
  const MyDonationsScreen({super.key, required this.user});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List donationList = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Donation History"), backgroundColor: Colors.orange),
      drawer: MyDrawer(user: widget.user),
      body: donationList.isEmpty
          ? Center(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))
          : ListView.builder(
              itemCount: donationList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.monetization_on, color: Colors.green, size: 40),
                    title: Text("RM ${donationList[index]['amount']}"),
                    subtitle: Text("To Pet ID: ${donationList[index]['pet_id']}\nDate: ${donationList[index]['donation_date']}"),
                    isThreeLine: true,
                    trailing: Text(donationList[index]['donation_type'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
                );
              },
            ),
    );
  }

  void loadDonations() {
    http.get(Uri.parse("${MyConfig.baseUrl}/pawpal/api/get_my_donations.php?userid=${widget.user.userId}"))
    .then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          setState(() {
            donationList = jsondata['data'];
            status = "Loaded";
          });
        } else {
          setState(() => status = "No donation history found.");
        }
      } else {
        setState(() => status = "Server Error");
      }
    });
  }
}
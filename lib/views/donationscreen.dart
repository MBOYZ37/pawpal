import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class DonationScreen extends StatefulWidget {
  final User user;
  final Pet pet;

  const DonationScreen({super.key, required this.user, required this.pet});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  
  String selectedType = "Money";
  final List<String> donationTypes = ["Money", "Food", "Medical", "Toys"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donate to Pet"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Donating to: ${widget.pet.petName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: selectedType,
              decoration: const InputDecoration(labelText: "Donation Type", border: OutlineInputBorder()),
              items: donationTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => selectedType = val.toString()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Amount (RM)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Message", border: OutlineInputBorder(), prefixIcon: Icon(Icons.message)),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: submitDonation,
                child: const Text("Confirm Donation", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitDonation() {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter an amount")));
      return;
    }

    http.post(Uri.parse("${MyConfig.baseUrl}/pawpal/api/payment.php"), body: {
      "email": widget.user.userEmail ?? "test@gmail.com",
      "phone": widget.user.userPhone ?? "0123456789",
      "name": widget.user.userName ?? "Anonymous",
      "amount": amountController.text,
      "description": "Donation for ${widget.pet.petName}",
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          _launchPaymentUrl(jsondata['url']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Creation Failed")));
        }
      }
    });
  }

  // Helper to open the browser
  Future<void> _launchPaymentUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      _showPaymentConfirmationDialog();
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showPaymentConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Status"),
        content: const Text("Please complete the payment in the browser tab that just opened.\n\nDid you complete the payment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               saveDonationToDatabase();
            },
            child: const Text("Yes, I paid"),
          ),
        ],
      ),
    );
  }

  void saveDonationToDatabase() {
    http.post(Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_donation.php"), body: {
      "user_id": widget.user.userId,
      "pet_id": widget.pet.petId,
      "donation_type": selectedType,
      "amount": amountController.text,
      "description": descController.text,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Donation Recorded!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsondata['message'])));
        }
      }
    });
  }
}
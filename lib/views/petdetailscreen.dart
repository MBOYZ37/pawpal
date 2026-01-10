import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/loginscreen.dart';
import 'package:pawpal/views/donationscreen.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;
  final User? user;

  const PetDetailsScreen({super.key, required this.pet, required this.user});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.petName ?? "Details"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenHeight * 0.4,
              width: screenWidth,
              color: Colors.grey[200],
              child: widget.pet.imagesPath.isEmpty
                  ? const Center(child: Icon(Icons.pets, size: 60, color: Colors.grey))
                  : PageView.builder(
                      itemCount: widget.pet.imagesPath.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          "${MyConfig.baseUrl}/pawpal/uploads/${widget.pet.imagesPath[index]}",
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => const Icon(Icons.broken_image),
                        );
                      },
                    ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.pet.petName ?? "No Name",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.pet.category ?? "Unknown",
                          style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("Type: ${widget.pet.petType}", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  
                  const SizedBox(height: 20),

                  const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.pet.description ?? "No description provided.",
                    style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text("Owner Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.pet.name ?? "Unknown Owner", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Joined: ${widget.pet.regDate?.substring(0, 10) ?? 'N/A'}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        confirmAdoption();
                      },
                      child: const Text("Request to Adopt", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                         if (widget.user == null || widget.user!.userId == '0') {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to donate.")));
                            return;
                         }

                         Navigator.push(context, MaterialPageRoute(builder: (context) => DonationScreen(
                           user: widget.user!, 
                           pet: widget.pet
                         )));
                      },
                      child: const Text("Donate to this Pet", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void confirmAdoption() {
    if (widget.user == null || widget.user!.userId == null || widget.user!.userId == '0') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to adopt.")));
      Navigator.push(context, MaterialPageRoute(builder: (content) => const LogInScreen()));
      return;
    }

    if (widget.user!.userId == widget.pet.userId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You cannot adopt your own pet!")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adopt Pet"),
        content: Text("Are you sure you want to request to adopt ${widget.pet.petName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              submitAdoption();
            },
            child: const Text("Yes, Request"),
          ),
        ],
      ),
    );
  }

  void submitAdoption() {
    http.post(
      Uri.parse("${MyConfig.baseUrl}/pawpal/api/submit_adoption.php"),
      body: {
        "pet_id": widget.pet.petId,
        "user_id": widget.user!.userId,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adoption Request Sent!"), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message']), backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server Error"), backgroundColor: Colors.red));
      }
    });
  }
}
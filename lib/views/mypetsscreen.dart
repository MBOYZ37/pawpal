import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/views/submitpetscreen.dart';
import 'package:pawpal/views/editpetscreen.dart';

class MyPetsScreen extends StatefulWidget {
  final User user;
  const MyPetsScreen({super.key, required this.user});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  List<Pet> petList = [];
  String status = "Loading...";
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    loadMyPets();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(onPressed: loadMyPets, icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      body: petList.isEmpty
          ? Center(child: Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
              itemCount: petList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditPetScreen(
                                  user: widget.user, 
                                  pet: petList[index]
                              )));
                      loadMyPets();
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "${MyConfig.baseUrl}/pawpal/uploads/${petList[index].imagesPath.isNotEmpty ? petList[index].imagesPath[0] : 'default.png'}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                petList[index].petName ?? "No Name",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text("Category: ${petList[index].category}"),
                              Text("Status: ${petList[index].petType}"),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: const Text("Tap to Edit", style: TextStyle(fontSize: 10, color: Colors.blue)),
                              )
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.edit, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubmitPetScreen(user: widget.user)));
          loadMyPets();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void loadMyPets() {
    String url = "${MyConfig.baseUrl}/pawpal/api/get_user_pets.php?userid=${widget.user.userId}";

    setState(() {
      status = "Loading...";
      petList.clear();
    });

    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            petList = (jsonResponse['data'] as List).map((data) => Pet.fromJson(data)).toList();
            status = "Loaded";
          });
        } else {
          setState(() {
            status = "You have no pets listed yet.";
          });
        }
      } else {
        setState(() {
          status = "Error loading data.";
        });
      }
    });
  }
}
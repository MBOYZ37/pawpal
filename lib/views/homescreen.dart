import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/loginscreen.dart';
import 'package:pawpal/views/submitpetscreen.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> petList = [];
  String status = "Loading...";
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    loadPets('');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Paw Pal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 177, 177, 177),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearchDialog();
            },
          ),
          IconButton(
            onPressed: () {
              loadPets('');
            },
            icon: Icon(Icons.refresh),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogInScreen()),
              );
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: Column(
            children: [
              petList.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.find_in_page_outlined, size: 64),
                            SizedBox(height: 12),
                            Text(
                              status,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: petList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.cyan[100],
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width:
                                          screenWidth * 0.28, // more responsive
                                      height:
                                          screenWidth *
                                          0.22, // balanced aspect ratio
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        // path to retrieve image from server
                                        '${MyConfig.baseUrl}/pawpal/${petList[index].imagesPath[0]}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // TEXT AREA
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // TITLE
                                        Text(
                                          petList[index].petName.toString(),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 4),

                                        // DESCRIPTION
                                        Text(
                                          petList[index].description.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          children: [
                                            // Category Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                petList[index].category
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                    255,
                                                    1,
                                                    1,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            // Pet Type Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                petList[index].petType
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Action for the button
          if (widget.user?.userId == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please login first/or register first"),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogInScreen()),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitPetScreen(user: widget.user),
              ),
            );
            loadPets('');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Enter search query'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                String search = searchController.text;
                if (search.isEmpty) {
                  loadPets('');
                } else {
                  loadPets(search);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void loadPets(String searchQuery) {
    petList.clear();
    setState(() {
      status = "Loading...";
    });

    http
        .get(
          Uri.parse(
            //api path to get pets
            '${MyConfig.baseUrl}/pawpal/API/get_my_pets.php?search=$searchQuery',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);

            if (jsonResponse['status'] == 'success' &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              petList.clear();
              for (var item in jsonResponse['data']) {
                petList.add(Pet.fromJson(item));
              }

              setState(() {
                status = "";
              });
            } else {
              setState(() {
                petList.clear();
                status = "No submissions yet";
              });
            }
          } else {
            setState(() {
              petList.clear();
              status = "Failed to load list of pets";
            });
          }
        });
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;

  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  List<String> petTypes = [
    'Cat',
    'Dog',
    'Bird',
    'Rabbit',
    'Fish',
    'Hamster',
    'Reptile',
    'Other',
  ];

  List<String> categories = [
    'Adoption',
    'Lost',
    'Found',
    'Donation Request',
    'Help / Rescue ',
  ];
  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  String selectedpet = 'Cat';
  String selectedcategory = 'Adoption';
  File? image;
  Uint8List? webImage; // for web
  late double height, width;
  late Position mypostion;
  List<File> images = []; // store multiple images

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 177, 177, 177),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Add Pets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickimagedialog,
                    child: Container(
                      width: width,
                      height: height / 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: images.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Tap to add images",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(
                              height: height / 3, // height of image boxes
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            images[index],
                                            width: width / 2.2, // box width
                                            height: height / 3,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                images.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: petNameController,
                    decoration: InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Pet Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    items: petTypes.map((String selectpet) {
                      return DropdownMenuItem<String>(
                        value: selectpet,
                        child: Text(selectpet),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedpet = newValue!;
                      });
                    },
                  ),

                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedcategory = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    controller: latController,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          mypostion = await _determinePosition();
                          latController.text = mypostion.latitude.toString();
                          setState(() {});
                        },
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    controller: lngController,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          mypostion = await _determinePosition();
                          lngController.text = mypostion.longitude.toString();
                          setState(() {});
                        },
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 237, 143, 62),
                      foregroundColor: Colors.white,
                      minimumSize: Size(width, 50),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      showSubmitDialog();
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pickimagedialog() {
    if (images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only upload up to 3 images"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Determine the current position of the device.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Open camera to take a picture
  Future<void> openCamera() async {
    if (images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 images allowed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      images.add(File(pickedFile.path));
      cropImage(images.length - 1);
    }
  }

  // Open gallery to select a picture
  Future<void> openGallery() async {
    if (images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 images allowed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      images.add(File(pickedFile.path));
      cropImage(images.length - 1);
    }
  }

  // Crop the selected image
  Future<void> cropImage(int index) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index].path,
      aspectRatio: CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Please Crop Your Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      images[index] = File(croppedFile.path);
      setState(() {});
    }
  }

  void showSubmitDialog() {
    // Pet Name validation
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter pet name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedpet.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a pet type"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Category validation
    if (selectedcategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a category"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Image validation
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Description
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //latitude validation
    if (latController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please click the location icon to get your current latitude",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //longitude validation
    if (lngController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please click the location icon to get your current longitude",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Pet'),
          content: const Text('Are you sure you want to submit this pet?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                submitPets();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Submit pet data to the server
  void submitPets() {
    List<String> base64Images = [];
    for (var img in images) {
      base64Images.add(base64Encode(img.readAsBytesSync()));
    }
    String petName = petNameController.text.trim();
    String description = descriptionController.text.trim();
    String lat = latController.text.trim();
    String lng = lngController.text.trim();

    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/API/submit_pets.php'),
          body: {
            // send to API
            'user_id': widget.user?.userId,
            'pet_name': petName,
            'pet_type': selectedpet,
            'category': selectedcategory,
            'description': description,
            'images': jsonEncode(base64Images), // send as JSON array
            'lat': lat.toString(),
            'lng': lng.toString(),
          },
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            if (resarray['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pet submitted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
  }
}
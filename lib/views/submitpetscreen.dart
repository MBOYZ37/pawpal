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

  String selectedPet = 'Cat';
  String selectedCategory = 'Adoption';

  List<File> images = []; // Mobile
  List<Uint8List> webImages = []; // Web

  late Position myPosition;
  late double width, height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) width = 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 177, 177, 177),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Pets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment:CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: pickImageDialog,
                child: Container(
                  height: height / 3.2,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey.shade500),
                  ),
                  child: buildImagePreview(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width:width *0.9, 
                child: TextField(
                  controller: petNameController,
                  decoration: _styledInput("Pet Name"),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: width * 0.9,
                child: DropdownButtonFormField<String>(
                  decoration: _styledInput("Select Pet Type"),
                  initialValue: selectedPet,
                  items: petTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedPet = v!),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: width * 0.9,
                child: DropdownButtonFormField<String>(
                  decoration: _styledInput("Select Category"),
                  initialValue: selectedCategory,
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: width * 0.9,
                child: TextField(
                  controller: descriptionController,
                  decoration: _styledInput("Description"),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 14),
              // LATITUDE FIELD
              SizedBox(
                width: width * 0.9,
                child: TextField(
                  controller: latController,
                  readOnly: true,
                  decoration: _styledInput("Latitude").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.location_on, color: Colors.orange),
                      tooltip: "Get Current Location",
                      onPressed: _getLocation, // Calls the helper function below
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // LONGITUDE FIELD
              SizedBox(
                width: width * 0.9,
                child: TextField(
                  controller: lngController,
                  readOnly: true, // Make it read-only so user must use the button
                  decoration: _styledInput("Longitude").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.location_on, color: Colors.orange),
                      tooltip: "Get Current Location",
                      onPressed: _getLocation, // Calls the helper function below
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: width * 0.9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 143, 62),
                    minimumSize: Size(width, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: showSubmitDialog,
                  child: const Text('Submit', style: TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _styledInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 237, 143, 62),
          width: 2,
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    final totalImages = kIsWeb ? webImages.length : images.length;
    if (totalImages == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo, size: 85, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Tap to upload up to 3 images",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      );
    } else {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(6),
        itemCount: totalImages,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: kIsWeb
                    ? Image.memory(
                        webImages[index],
                        width: width / 2.2,
                        height: height / 3.2,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        images[index],
                        width: width / 2.2,
                        height: height / 3.2,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (kIsWeb) {
                        webImages.removeAt(index);
                      } else {
                        images.removeAt(index);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void pickImageDialog() {
    if ((kIsWeb ? webImages.length : images.length) >= 3) {
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
          title: const Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
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

  Future<void> openCamera() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera not supported on Web"),
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

  Future<void> openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();
        webImages.add(bytes);
      } else {
        images.add(File(pickedFile.path));
        cropImage(images.length - 1);
      }
      setState(() {});
    }
  }

  Future<void> cropImage(int index) async {
    if (kIsWeb) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index].path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
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
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter pet name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if ((kIsWeb ? webImages.isEmpty : images.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );
  }

  void submitPets() {
    List<String> base64Images = [];
    
    // 1. Convert images based on platform
    if (kIsWeb) {
      for (var bytes in webImages) {
        base64Images.add(base64Encode(bytes));
      }
    } else {
      for (var f in images) {
        base64Images.add(base64Encode(f.readAsBytesSync()));
      }
    }

    // 2. Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    print("Submitting to: ${MyConfig.baseUrl}/pawpal/api/submit_pet.php"); // DEBUG PRINT

    http.post(
      Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
      body: {
        'user_id': widget.user?.userId,
        'pet_name': petNameController.text.trim(),
        'pet_type': selectedPet,
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'images': jsonEncode(base64Images),
        'lat': latController.text.trim().isEmpty ? "0.0" : latController.text.trim(), // Default to 0.0 if empty
        'lng': lngController.text.trim().isEmpty ? "0.0" : lngController.text.trim(),
      },
    ).then((response) {
      Navigator.pop(context); // Close Loading Dialog
      
      print("Response Status: ${response.statusCode}"); // DEBUG PRINT
      print("Response Body: ${response.body}"); // DEBUG PRINT

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (mounted) {
          if (res['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Pet submitted successfully"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Go back to Home
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['message'] ?? "Unknown Error"), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    }).catchError((error) {
      Navigator.pop(context); // Close Loading Dialog
      print("Error: $error"); // DEBUG PRINT
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Failed: $error"), backgroundColor: Colors.red),
      );
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable GPS.');
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied. Please allow location in your browser settings.');
    }

    // 3. Get Position (with Web Settings for better compatibility)
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  void _getLocation() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Getting location...")),
      );

      Position pos = await _determinePosition();

      setState(() {
        latController.text = pos.latitude.toString();
        lngController.text = pos.longitude.toString();
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      print("Location Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

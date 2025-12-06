import 'dart:convert';
import 'dart:io';
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
    'Help / Rescue',
  ];

  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();

  String selectedPet = 'Cat';
  String selectedCategory = 'Adoption';

  late double height, width;
  late Position myPosition;
  List<File> images = [];

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    if (width > 600) width = 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 177, 177, 177),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Pets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: height / 3.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.grey.shade500),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 38),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: images.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 85,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Tap to upload up to 3 images",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(6),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
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
                                          images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 140,
                                          ),
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
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: petNameController,
                  decoration: _styledInput("Pet Name"),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedPet,
                  decoration: _styledInput("Select Pet Type"),
                  items: petTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedPet = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: _styledInput("Select Category"),
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionController,
                  decoration: _styledInput("Description"),
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: latController,
                  readOnly: true,
                  decoration: _styledInput("Latitude").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () async {
                        myPosition = await _determinePosition();
                        latController.text = myPosition.latitude.toString();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: lngController,
                  readOnly: true,
                  decoration: _styledInput("Longitude").copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: () async {
                        myPosition = await _determinePosition();
                        lngController.text = myPosition.longitude.toString();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 143, 62),
                    foregroundColor: Colors.white,
                    minimumSize: Size(width, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: showSubmitDialog,
                  child: const Text('Submit', style: TextStyle(fontSize: 17)),
                ),
                const SizedBox(height: 12),
              ],
            ),
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
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 237, 143, 62),
          width: 2,
        ),
      ),
    );
  }

  void pickImage() {
    if (images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 images allowed"),
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
                  _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Your Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Cropper'),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          images.add(File(croppedFile.path));
        });
      }
    }
  }

  List<String> getBase64Images() =>
      images.map((img) => base64Encode(img.readAsBytesSync())).toList();

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied)
      return Future.error('Location permissions are denied');
    if (permission == LocationPermission.deniedForever)
      return Future.error('Location permissions are permanently denied.');

    return await Geolocator.getCurrentPosition();
  }

  void showSubmitDialog() {
    if (petNameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        latController.text.trim().isEmpty ||
        lngController.text.trim().isEmpty ||
        images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  void submitPets() {
    List<String> base64Images = getBase64Images();
    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/API/submit_pet.php'),
          body: {
            'user_id': widget.user?.userId,
            'pet_name': petNameController.text.trim(),
            'pet_type': selectedPet,
            'category': selectedCategory,
            'description': descriptionController.text.trim(),
            'images': jsonEncode(base64Images),
            'lat': latController.text.trim(),
            'lng': lngController.text.trim(),
          },
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var resArray = jsonDecode(response.body);
            if (mounted) {
              if (resArray['status'] == 'success') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pet submitted successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(resArray['message']),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        });
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passController;

  int val = 0;
  bool _isEditing = false;
  XFile? _image;
  late double screenHeight, screenWidth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.userName);
    _phoneController = TextEditingController(text: widget.user.userPhone);
    _emailController = TextEditingController(text: widget.user.userEmail);
    _passController = TextEditingController(); 
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? "Cancel Editing" : "Edit Profile",
          )
        ],
      ),
      drawer: MyDrawer(user: widget.user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _selectImage : null,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 3),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _getImageProvider(), 
                        onError: (exception, stackTrace) {
                        },
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.orange),
                    )
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField("Name", _nameController, Icons.person, false),
            _buildTextField("Email", _emailController, Icons.email, true),
            _buildTextField("Phone", _phoneController, Icons.phone, false),
            
            if (_isEditing)
              _buildTextField("New Password (Leave empty to keep)", _passController, Icons.lock, false, isObscure: true),

            const SizedBox(height: 20),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: updateProfile,
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (_image != null) {
      if (kIsWeb) {
        return NetworkImage(_image!.path);
      } else {
        return FileImage(File(_image!.path));
      }
    } else {
      return NetworkImage(
          "${MyConfig.baseUrl}/pawpal/assets/profile/profile_${widget.user.userId}.png?v=$val");
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isReadOnly, {bool isObscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly || !_isEditing, 
        obscureText: isObscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: isReadOnly || !_isEditing,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  void _selectImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Image From"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 40, color: Colors.orange)),
            IconButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image, size: 40, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void updateProfile() async {
    String base64Image = "";
    
    if (_image != null) {
      var bytes = await _image!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    http.post(Uri.parse("${MyConfig.baseUrl}/pawpal/api/update_profile.php"), body: {
      "userid": widget.user.userId,
      "name": _nameController.text,
      "phone": _phoneController.text,
      "password": _passController.text,
      "image": base64Image,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
          
          setState(() {
            widget.user.userName = _nameController.text;
            widget.user.userPhone = _phoneController.text;
            _isEditing = false;
            _image = null; 
            val = val + 1; 
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsondata['message'] ?? "Update Failed")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server Error")));
      }
    });
  }
}
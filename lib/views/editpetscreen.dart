import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';

class EditPetScreen extends StatefulWidget {
  final User user;
  final Pet pet;

  const EditPetScreen({super.key, required this.user, required this.pet});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> petTypes = [
    'Cat',
    'Dog',
    'Bird',
    'Rabbit',
    'Fish',
    'Hamster',
    'Reptile',
    'Other',
  ];
  final List<String> categories = [
    'Adoption',
    'Lost',
    'Found',
    'Donation Request',
    'Help / Rescue ',
    ];
  
  String selectedPetType = "Cat";
  String selectedCategory = "Adoption";

  @override
  void initState() {
    super.initState();
    petNameController.text = widget.pet.petName.toString();
    descriptionController.text = widget.pet.description.toString();
    selectedPetType = widget.pet.petType.toString();
    selectedCategory = widget.pet.category.toString();

    if (!petTypes.contains(selectedPetType)) selectedPetType = petTypes[0];
    if (!categories.contains(selectedCategory)) selectedCategory = categories[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pet"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              confirmDelete();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: petNameController,
              decoration: const InputDecoration(
                labelText: "Pet Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: selectedPetType,
              decoration: const InputDecoration(
                labelText: "Pet Type",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: petTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (newValue) {
                setState(() => selectedPetType = newValue.toString());
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (newValue) {
                setState(() => selectedCategory = newValue.toString());
              },
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: updatePet,
                child: const Text("Update Pet", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updatePet() {
    http.post(Uri.parse("${MyConfig.baseUrl}/pawpal/api/update_pet.php"), body: {
      "pet_id": widget.pet.petId,
      "pet_name": petNameController.text,
      "pet_type": selectedPetType,
      "category": selectedCategory,
      "description": descriptionController.text,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Success")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsondata['message'])));
        }
      }
    });
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pet"),
        content: const Text("Are you sure you want to delete this pet?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePet();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deletePet() {
    http.post(Uri.parse("${MyConfig.baseUrl}/pawpal/api/delete_pet.php"), body: {
      "pet_id": widget.pet.petId,
    }).then((response) {
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete Success")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsondata['message'])));
        }
      }
    });
  }
}
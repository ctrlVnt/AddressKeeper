import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'home.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? name;
  String? phone;
  String? address;
  String? profileImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPersonalData();
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission to access photos is required.')),
        );
        return;
      }
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profileImagePath = image.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', image.path);
    }
  }

  Future<void> _loadPersonalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
      phone = prefs.getString('phone');
      address = prefs.getString('address');
      profileImagePath = prefs.getString('profile_image'); // optional
    });
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('address', _addressController.text);

    setState(() {
      name = _nameController.text;
      phone = _phoneController.text;
      address = _addressController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome!",
                    style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "This app works completely offline",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: _pickImage,
                    child: profileImagePath == null
                        ? Neumorphic(
                      style: const NeumorphicStyle(
                        shape: NeumorphicShape.convex,
                        depth: 8,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      child: const SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(
                          child: Icon(Icons.person, size: 50),
                        ),
                      ),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(profileImagePath!)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (name == null || phone == null || address == null) ...[
                    Neumorphic(
                        style: NeumorphicStyle(
                          depth: -4,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Name"
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: "Phone",
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) =>
                        value == null || value.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child:TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Address"
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveAndContinue();
                        }
                      },
                      child: const Text("Save and Continue"),
                    ),
                  ] else ...[
                    Text(name!, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text("Phone: $phone", style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text("Address: $address", style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    NeumorphicButton(
                      onPressed: (){
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: const Text("Continue"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movesync/database/database.dart';
import 'package:movesync/model/AppInfo.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'info.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentPhone = "";
  String currentAddress = "";
  String name = "";
  String profileImage = "";

  List<AppInfo> apps = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadAppsFromDB();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? currentPhone;
      currentPhone = prefs.getString('phone') ?? currentPhone;
      currentAddress = prefs.getString('address') ?? currentAddress;
      profileImage = prefs.getString('profile_image') ?? profileImage;
    });
  }

  void _editPersonalDataDialog() {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: currentPhone);
    final addressController = TextEditingController(text: currentAddress);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 8,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          ),
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit personal data", style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final status = await Permission.photos.request();
                    if (status.isGranted) {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          profileImage = pickedFile.path;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('profile_image', pickedFile.path);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Access gallery denied")),
                      );
                    }
                  },
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 4,
                      intensity: 0.8,
                    ),
                    child: profileImage == ""
                        ? SizedBox(
                      height: 80,
                      width: 80,
                      child: Icon(Icons.camera_alt, size: 40),
                    )
                        : CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(File(profileImage)),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _neumorphicInput("Your name", nameController),
                SizedBox(height: 12),
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: -3,
                    boxShape: NeumorphicBoxShape.stadium(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration.collapsed(hintText: "Telephone number"),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                SizedBox(height: 12),
                _neumorphicInput("Address", addressController),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NeumorphicButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    NeumorphicButton(
                      child: Text(
                          "Save",
                        style: TextStyle(
                          color: Colors.black
                        ),
                      ),
                      style: NeumorphicStyle(
                        color: Colors.green,
                      ),
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newPhone = phoneController.text.trim();
                        final newAddress = addressController.text.trim();

                        if (newName.isNotEmpty && newPhone.isNotEmpty && newAddress.isNotEmpty) {
                          setState(() {
                            name = newName;
                            currentPhone = newPhone;
                            currentAddress = newAddress;
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('name', newName);
                          await prefs.setString('phone', newPhone);
                          await prefs.setString('address', newAddress);

                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Insert all fields")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _neumorphicInput(String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -3,
        boxShape: NeumorphicBoxShape.stadium(),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        keyboardType: keyboardType,
      ),
    );
  }

  Future<void> _loadAppsFromDB() async {
    final data = await DatabaseHelper.instance.getAllApps();
    setState(() {
      apps = data;
    });
  }

  void _addAppDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 8,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("New app", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 16),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: -3,
                  boxShape: NeumorphicBoxShape.stadium(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration.collapsed(hintText: "App or website name"),
                ),
              ),
              SizedBox(height: 12),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: -3,
                  boxShape: NeumorphicBoxShape.stadium(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  controller: urlController,
                  decoration: InputDecoration.collapsed(hintText: "Link (otional)"),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  NeumorphicButton(
                    child: Text(
                        "Add",
                      style: TextStyle(
                        color: Colors.black
                      ),
                    ),
                    style: NeumorphicStyle(
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      final appName = nameController.text.trim();
                      final url = urlController.text.trim().isNotEmpty ? urlController.text.trim() : null;

                      if (appName.isNotEmpty) {
                        final newApp = AppInfo(
                          appName: appName,
                          phone: currentPhone,
                          address: currentAddress,
                          url: url,
                        );

                        await DatabaseHelper.instance.insertApp(newApp);
                        await _loadAppsFromDB();
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Insert the app or website name")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _confirmRemoveApp(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 8,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Confirm",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16),
              Text(
                "Do you want to remove '${apps[index].appName}'?",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    style: NeumorphicStyle(depth: 4, boxShape: NeumorphicBoxShape.stadium()),
                    child: Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  NeumorphicButton(
                    style: NeumorphicStyle(
                      depth: 4,
                      boxShape: NeumorphicBoxShape.stadium(),
                      color: Theme.of(context).colorScheme.error,
                    ),
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.black
                      ),
                    ),
                    onPressed: () async {
                      final appName = apps[index].appName;
                      await DatabaseHelper.instance.deleteApp(appName);
                      await _loadAppsFromDB();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("not valid link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColorError = theme.colorScheme.error;

    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text('Home',style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          NeumorphicButton(
            child: Icon(
              Icons.info_outline,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            style: NeumorphicStyle(
              depth: 0,
              boxShape: NeumorphicBoxShape.circle(),
            ),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => InfoPage()),
              );
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child:
                  Column(
                    children: [
                      Neumorphic(
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.circle(),
                          depth: 4,
                          intensity: 0.8,
                          lightSource: LightSource.topLeft,
                          color: Colors.white,
                        ),
                        child: profileImage == ""
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
                          backgroundImage: FileImage(File(profileImage!)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      Text(currentPhone, style: theme.textTheme.bodyLarge),
                      Text(currentAddress, style: theme.textTheme.bodyLarge),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center, // o Alignment.centerLeft / right
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: NeumorphicButton(
                            onPressed: _editPersonalDataDialog,
                            child: Text("Edit personal data"),
                          ),
                        ),
                      )
                    ],
                  ),

          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Apps", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isPhoneMatching = app.phone == currentPhone;
                final isAddressMatching = app.address == currentAddress;

                final needsUpdate = !isPhoneMatching || !isAddressMatching;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -4,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.appName,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Number: ${app.phone}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isPhoneMatching ? null : textColorError,
                                  ),
                                ),
                                Text(
                                  "Address: ${app.address}",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isAddressMatching ? null : textColorError,
                                  ),
                                ),
                                if (app.url != null)
                                  GestureDetector(
                                    onTap: () => _launchURL(app.url!),
                                    child: Text(
                                      app.url!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                if (needsUpdate)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: NeumorphicButton(
                                      style: NeumorphicStyle(
                                        depth: 4,
                                        boxShape: NeumorphicBoxShape.stadium(),
                                      ),
                                      onPressed: () async {
                                        final updatedApp = AppInfo(
                                          appName: app.appName,
                                          phone: currentPhone,
                                          address: currentAddress,
                                          url: app.url,
                                        );
                                        await DatabaseHelper.instance.updateApp(updatedApp);
                                        await _loadAppsFromDB();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("data updated for '${app.appName}'")),
                                        );
                                      },
                                      child: Text(
                                        "update data",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          NeumorphicButton(
                            child: Icon(Icons.delete, color: theme.colorScheme.error),
                            style: const NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.circle(),
                            ),
                            onPressed: () => _confirmRemoveApp(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        style: NeumorphicStyle(
          color: Colors.grey,
          boxShape: NeumorphicBoxShape.circle(),
        ),
        onPressed: _addAppDialog,
        tooltip: "Add app",
        child: Icon(
          Icons.add,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}

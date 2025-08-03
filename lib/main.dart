import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import 'home.dart';
import 'welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = await SharedPreferences.getInstance();
  final hasName = prefs.getString('name') != null;

  runApp(MyApp(showWelcome: !hasName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showWelcome});

  final bool showWelcome;

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Address up',
      themeMode: ThemeMode.system,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        shadowLightColor: Colors.grey.shade700,
        depth: 3,
      ),
      home: showWelcome
          ? WelcomeScreen()
          : HomePage(),
    );
  }
}

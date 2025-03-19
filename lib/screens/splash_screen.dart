import 'dart:async';
import 'package:flutter/material.dart';
import 'package:green_guide/screens/ai/plant_care.dart';
import 'package:green_guide/screens/admin/admin_panel.dart';
import 'package:green_guide/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Show splash screen for 3 seconds, then check role
    Timer(Duration(seconds: 3), _checkUserRole);
  }

  // Function to check the user role after splash screen
  Future<void> _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    String? role = prefs.getString('user_role');

    if (token != null && role != null) {
      if (role.toLowerCase() == "admin") {
        // Navigate to Admin Panel if the user is an admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanelScreen()),
        );
      } else {
        // Navigate to HomeScreen for non-admin users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PlantCare()),
        );
      }
    } else {
      // Navigate to LoginScreen if no valid token/role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/logo.png'), // Your logo image here
      ),
    );
  }
}

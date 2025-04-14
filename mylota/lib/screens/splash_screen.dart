import 'package:flutter/material.dart';
import 'package:mylota/screens/login_page.dart';
import 'main_screen.dart'; // Replace with the home page of your app.

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the main screen after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Background Gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/images/logo.png', // Path to your logo
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                'Mylota Fitness',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Changed for better visibility
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 10),

              // Tagline
              Text(
                'Your Journey to Wellness Starts Here',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.8), // Changed for better visibility
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 50),

              // Loading Indicator
              const CircularProgressIndicator(
                color: Color(0xFF2A7F67), // Matches the theme colors
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

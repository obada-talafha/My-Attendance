import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Make sure this path is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp(); // Call the initialization logic
  }

  Future<void> _initializeApp() async {
    // Ensure the splash screen is shown for at least 2 seconds for a good UX
    final Future<void> minimumDisplayTime = Future.delayed(const Duration(seconds: 2));

    bool loggedIn = false;
    String? role;

    try {
      loggedIn = await AuthService.isLoggedIn();
      if (loggedIn) {
        role = await AuthService.getUserRole();
      }
    } catch (e) {
      // Handle authentication service errors (e.g., network issues)
      print('Authentication initialization error: $e');
      if (mounted) {
        // Show a snackbar or navigate to an error specific screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize. Please check your connection.')),
        );
      }
      loggedIn = false; // Treat as not logged in on error
    }

    // Wait for both the minimum display time and the authentication check to complete
    await minimumDisplayTime;

    if (!mounted) return; // Check if the widget is still in the widget tree

    if (!loggedIn) {
      // If not logged in or an error occurred during login check
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // If logged in, navigate based on role
      if (role != null) {
        Navigator.pushReplacementNamed(context, '/$role');
      } else {
        // Fallback: If logged in but role is somehow null (unexpected scenario)
        print('User is logged in but role is null. Navigating to login.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo
            Image.asset(
              'asset/logo.png', // Ensure this path is correct in your project
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 30), // Space between logo and indicator
            // Loading indicator to show activity
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
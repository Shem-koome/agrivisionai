import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package
import 'landing_page.dart'; // Import your landing page
import 'main.dart'; // Import your main.dart file for navigation

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true; // To track loading state
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No internet connection. Please check your connection.';
      });
    } else {
      navigateToNextScreen();
    }
  }

  Future<void> navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5));
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null 
            ? CropYieldDashboardScreen(user: user) // Home screen for logged in user
            : const LandingPage(), // Landing page for not logged in user
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: _isLoading 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/ic_launcher.png', // Replace with your logo path
                    height: 200, // Set the desired height
                    width: 200, // Set the desired width
                    fit: BoxFit.cover, // Ensure the image covers the circular area
                  ),
                ),
                const SizedBox(height: 20), // Space between image and spinner
                const CircularProgressIndicator(
                  color: Colors.green, // Green spinner
                ),
              ],
            ) 
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Retry connectivity check
                      checkConnectivity();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
      ),
    );
  }
}

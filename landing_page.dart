import 'package:flutter/material.dart';
import 'sign_in_form.dart';
import 'create_account_form.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isSignIn = true;

  void toggleForm() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
          children: [
            // Image displayed before the forms in a circular shape
            ClipOval(
              child: Image.asset(
                'assets/icon.png', // Update with your image path
                height: 200, // Set the desired height
                width: 200, // Set the desired width
                fit: BoxFit.cover, // Ensure the image covers the circular area
              ),
            ),
            const SizedBox(height: 20), // Adjust space between image and forms
            _isSignIn ? const SignInForm() : const CreateAccountForm(),
          ],
        ),
      ),
      bottomNavigationBar: TextButton(
        onPressed: toggleForm,
        child: Text(
          _isSignIn ? 'Don\'t have an account? Create one' : 'Already have an account? Sign in',
          style: const TextStyle(color: Colors.green), // Set text color to green
        ),
      ),
    );
  }
}

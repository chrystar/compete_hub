import 'package:compete_hub/core/utils/app_colors.dart';
import 'package:compete_hub/src/screens/main_home_screen/main_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart'; // Import for Firebase Auth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Define controllers for the text fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // A GlobalKey to access the form's state for validation.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Instance of AuthProvider

  // State variable to manage password visibility.
  bool _obscureText = true;

  // This method handles the login process using the AuthProvider.
  void _handleLogin(BuildContext context) async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        // Show a loading indicator.
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Use the AuthProvider to sign in.
        await authProvider.signInWithEmailAndPassword(email, password);

        // Hide the dialog.
        Navigator.of(context).pop();

        // ignore: avoid_print
        print('Login Successful!');
        // Navigate to the main event listing screen (or your main screen).
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const MainHomeScreen(), // Replace with your main screen
          ),
        );

        // Clear the form fields.
        _emailController.clear();
        _passwordController.clear();
      } catch (e) {
        // Hide the dialog.
        Navigator.of(context).pop();
        // Show the error message from the AuthProvider.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Always dispose of TextEditingController objects to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary, // Use theme's background
      body: Padding(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            // Center the content vertically
            children: <Widget>[
              // Email Text Field
              Text(
                'C-vent',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  // Moved email validation regex to AuthProvider
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              // Password Text Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    // Added a suffix icon to toggle password visibility
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // updates the state
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Login Button
              GestureDetector(
                onTap: () => _handleLogin(context),
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade700,
                        Colors.blue.shade900,
                        Colors.blue.shade900,
                        // Colors.blue,
                        Colors.deepPurple.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              // Forgot Password Button
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality.
                  // This is a placeholder for future implementation.
                  // ignore: avoid_print
                  print('Forgot Password? button pressed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    // added context
                    const SnackBar(
                      content: Text(
                          'Forgot Password functionality not implemented yet.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



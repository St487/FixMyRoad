import 'package:fix_my_road/animation/animated_button.dart';
import 'package:fix_my_road/animation/transition.dart';
import 'package:fix_my_road/screen/forgot_password.dart';
import 'package:fix_my_road/screen/home_page.dart';
import 'package:fix_my_road/screen/registration_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Set a max width for large screens
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 248, 187, 222),
              Color.fromARGB(255, 252, 217, 192),
              Color.fromARGB(255, 204, 192, 249),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),

        //white card
        child: Center(
          child: Container(
            width: containerWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),

            // Login form
            child: Column(
              mainAxisSize: MainAxisSize.min, // <- makes height fit content
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Please log in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Email and Password fields
                TextField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Remember Me and Forgot Password
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [ 
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                      ],
                    ),
                  ],
                ),
                
                // Login Button
                const SizedBox(height: 15),
                AnimatedButton(
                  width: 250,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const HomePage();
                    }));
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                const Divider(height: 20, thickness: 1.5),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TransitionButton(page: const RegistrationScreen(), text: "Sign Up"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    TransitionButton.navigateWithSlide(context, const ForgotPassword());
                  },
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

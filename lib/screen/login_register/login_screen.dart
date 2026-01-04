import 'package:fix_my_road/animation/animated_button.dart';
import 'package:fix_my_road/animation/transition.dart';
import 'package:fix_my_road/main_screen.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/screen/forgot_password/forgot_password.dart';
import 'package:fix_my_road/screen/home_page.dart';
import 'package:fix_my_road/screen/login_register/registration_screen.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  bool _isPasswordVisible = false;
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Set a max width for large screens
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    final lang = context.watch<LanguageProvider>();

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
            padding: const EdgeInsets.all(30),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Language Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.language),
                      label: Text(lang.isEnglish ? 'BM' : 'EN'),
                      onPressed: () {
                        lang.toggleLanguage();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppText.welcome(lang.isEnglish),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppText.subtitle(lang.isEnglish),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
              
                  // Email and Password fields
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppText.email(lang.isEnglish),
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
                      labelText: AppText.password(lang.isEnglish),
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
              
                  // Remember Me
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
                          Text(AppText.rememberMe(lang.isEnglish)),
                        ],
                      ),
                    ],
                  ),
                  
                  // Login Button
                  const SizedBox(height: 15),
                  AnimatedButton(
                    width: 250,
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                        return const MainScreen();
                      }));
                    },
                    child: Text(
                      AppText.login(lang.isEnglish),
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
                      Text(AppText.noAccount(lang.isEnglish)),
                      TransitionButton(page: const RegistrationScreen(), text: AppText.signUp(lang.isEnglish)),
                    ],
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      TransitionButton.navigateWithSlide(context, const ForgotPassword());
                    },
                    child: Text(AppText.forgotPassword(lang.isEnglish)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

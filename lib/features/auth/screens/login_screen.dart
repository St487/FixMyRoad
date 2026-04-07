import 'package:fix_my_road/features/auth/controllers/authController.dart';
import 'package:fix_my_road/shared/animation/animated_button.dart';
import 'package:fix_my_road/shared/animation/transition.dart';
import 'package:fix_my_road/main_screen.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/features/password/screens/forgot_password.dart';
import 'package:fix_my_road/features/auth/screens/registration_screen.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/model/place_details.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(context, listen: false).loadRememberMe();
  }
  bool isChecked = false;
  bool _isPasswordVisible = false;
  bool isEnglish = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final auth = context.watch<AuthController>();

    // Set a max width for large screens
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      auth.setLanguage(lang); 
    });

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
                      label: Text(lang ? 'BM' : 'EN'),
                      onPressed: () {
                        languageProvider.toggleLanguage();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppText.welcome(lang),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppText.subtitle(lang),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
              
                  // Email and Password fields
                  TextField(
                    controller: auth.loginEmail,
                    decoration: InputDecoration(
                      labelText: AppText.email(lang),
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: auth.loginPassword,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: AppText.password(lang),
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
                            value: auth.rememberMe,
                            onChanged: (value) {
                              auth.rememberMe = value!;
                              auth.notifyListeners();
                            },
                          ),
                          Text(AppText.rememberMe(lang)),
                        ],
                      ),
                    ],
                  ),
                  
                  // Login Button
                  const SizedBox(height: 15),
                  AnimatedButton(
                    width: 250,
                    onPressed: () async {
                      final result = await context.read<AuthController>().login();

                      if (result['success']) {
                        auth.clearAll();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const MainScreen()));
                      } else {
                        CustomSnackbar.show(context, result['message'], Colors.redAccent, Colors.white);
                      }
                    },
                    child: Text(
                      AppText.login(lang),
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
                      Text(AppText.noAccount(lang)),
                      TransitionButton(page: const RegistrationScreen(), text: AppText.signUp(lang)),
                    ],
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      TransitionButton.navigateWithSlide(context, const ForgotPassword());
                    },
                    child: Text(AppText.forgotPassword(lang)),
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

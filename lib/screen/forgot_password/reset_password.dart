import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/screen/login_register/login_screen.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 20),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 8.0),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: Center(
                  child: Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/reset.png', height: 150),
                        SizedBox(height: 20),
                        Text(
                          AppText.resetPassword(lang.isEnglish),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          AppText.enterNewPassword(lang.isEnglish),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: AppText.newPassword(lang.isEnglish),
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            labelText: AppText.confirmPassword(lang.isEnglish),
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: ElevatedButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return const LoginScreen();
                              }));
                            }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 62, 129, 212),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),  
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              AppText.reset(lang.isEnglish),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
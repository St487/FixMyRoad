import 'package:fix_my_road/features/password/controllers/passwordController.dart';
import 'package:fix_my_road/shared/animation/transition.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/features/password/screens/passcode.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late PasswordController controller;
  bool isLoading = false;
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = PasswordController();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordController>();
    final emailController = TextEditingController();
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setLanguage(lang); 
    });
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
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
                        Image.asset('assets/images/forgotpassword.png', height: 150),
                        Text(
                          AppText.forgotYourPassword(lang),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppText.enterEmailResetCode(lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: AppText.emailAddress(lang),
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppText.rememberPassword(lang),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              }, 
                              child: Text(
                                AppText.loginShort(lang),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 62, 129, 212),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              final result = await controller.sendCode(emailController.text);

                              setState(() {
                                isLoading = false;
                              });

                              if (result['status'] == 'success') {
                                  controller.startResendTimer();
                                CustomSnackbar.show(
                                  context,
                                  AppText.verificationCodeSent(lang),
                                  Colors.green,
                                  Colors.white,
                                );

                                TransitionButton.navigateWithSlide(
                                  context,
                                  PasscodeScreen(email: emailController.text),
                                );
                              } else {
                                CustomSnackbar.show(
                                  context,
                                  result['message'] ?? 'Failed',
                                  Colors.redAccent,
                                  Colors.white,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 62, 129, 212),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),  
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  AppText.sendCode(lang),
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
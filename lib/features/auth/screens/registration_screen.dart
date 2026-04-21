import 'package:fix_my_road/features/auth/controllers/authController.dart';
import 'package:fix_my_road/shared/animation/animated_button.dart';
import 'package:fix_my_road/shared/animation/transition.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/features/auth/screens/complete_profile.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final screenHeight = MediaQuery.of(context).size.height;

    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

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
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 20.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.85,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppText.createAccount(lang),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            AppText.emailAddress(lang),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        TextField(
                          controller: auth.registerEmail,
                          decoration: InputDecoration(
                            hintText: AppText.inputEmail(lang),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            AppText.verificationCode(lang),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        TextField(
                          controller: auth.verificationCode,
                          decoration: InputDecoration(
                            hintText: AppText.inputVerificationCode(lang),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextButton(
                                onPressed: auth.countdown > 0
                                  ? null
                                  : () async {
                                      final result = await context.read<AuthController>().sendVerificationCode();

                                      if (!mounted) return;

                                      if (result['status'] == 'success') {
                                        context.read<AuthController>().startCountdown(); 

                                        CustomSnackbar.show(
                                          context,
                                          AppText.verificationCodeSent(lang),
                                          Colors.green,
                                          Colors.white,
                                        );
                                      } else {
                                        CustomSnackbar.show(
                                          context,
                                          result['message'],
                                          Colors.red,
                                          Colors.white,
                                        );
                                      }
                                    },
                                child: Text(
                                auth.countdown > 0
                                    ? "${auth.countdown}s"
                                    : AppText.verificationButton(lang),
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            AppText.phoneNumber(lang),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        TextField(
                          controller: auth.phone,
                          decoration: InputDecoration(
                            hintText: AppText.inputPhone(lang),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            AppText.password(lang),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        TextField(
                          controller: auth.password,
                          decoration: InputDecoration(
                            hintText: AppText.inputPassword(lang),
                            helperText: AppText.passwordHint(lang),
                            helperMaxLines: 2,
                            helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(
                            AppText.confirmPassword(lang),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        TextField(
                          controller: auth.confirmPassword,
                          decoration: InputDecoration(
                            hintText: AppText.inputConfirm(lang),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppText.haveAccount(lang),
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppText.login(lang),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        AnimatedButton(
                          width: 250,
                          isLoading: auth.isLoading,
                          onPressed: () async {
                            final result = await context.read<AuthController>().register();
                            if (!mounted) return;
                            if (result['status'] == 'success') {
                              CustomSnackbar.show(context, result['message'], Colors.greenAccent, Colors.white);
                              TransitionButton.navigateWithSlide(context, const CompleteProfile());
                              // auth.clearRegistrationFields();
                            } else {
                              CustomSnackbar.show(context,result['message'] ?? AppText.somethingWrong(lang), Colors.redAccent, Colors.white);
                            }
                          },
                          child: Text(
                            AppText.register(lang),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  )      
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
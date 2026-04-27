import 'package:fix_my_road/features/password/controllers/passwordController.dart';
import 'package:fix_my_road/shared/animation/transition.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fix_my_road/features/password/screens/reset_password.dart';
import 'package:provider/provider.dart';

class PasscodeScreen extends StatefulWidget {
  final String email;

  const PasscodeScreen({super.key, required this.email});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // start with first field focused
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _onCodeChanged(int index, String value) async {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // ONLY UI LOGIC HERE
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PasswordController>();
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setLanguage(lang); 
    });
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
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: containerWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/passcode.png', height: 150),
                        SizedBox(height: 20),
                        Text(
                          AppText.enterPasscode(lang),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppText.enterPasscodeDesc(lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            return SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _onCodeChanged(index, v),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppText.didntReceiveCode(lang),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: controller.resendCountdown == 0
                                  ? () async {
                                      HapticFeedback.lightImpact();
                                      final result = await controller.resendCode(widget.email);

                                      if (result['status'] == 'success') {
                                        controller.startResendTimer();

                                        CustomSnackbar.show(
                                          context,
                                          result['message'],
                                          Colors.green,
                                          Colors.white,
                                        );
                                      } else {
                                        CustomSnackbar.show(
                                          context,
                                          result['message'] ?? 'Failed',
                                          Colors.redAccent,
                                          Colors.white,
                                        );
                                      }
                                    }
                                  : null,
                              child: Text(
                                controller.resendCountdown == 0
                                    ? AppText.resend(lang)
                                    : "Resend in ${controller.resendCountdown}s",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: controller.resendCountdown == 0
                                      ? const Color.fromARGB(255, 62, 129, 212)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final controller = context.read<PasswordController>(); // IMPORTANT

    String code = _controllers.map((e) => e.text).join();

    final result = await controller.verifyCode(widget.email, code);

    if (!mounted) return;

    if (result['status'] == 'success') {
      TransitionButton.navigateWithSlide(
        context,
        ResetPassword(email: widget.email),
      );
    } else {
      CustomSnackbar.show(
        context,
        result['message'] ?? 'Invalid code',
        Colors.redAccent,
        Colors.white,
      );
    }
  }
}
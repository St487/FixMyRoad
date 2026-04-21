import 'dart:async';
import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PasswordController extends ChangeNotifier {
  final String baseUrl = MyConfig.myurl;
  bool isEnglish = true;
  bool mockVerification = true; // set false in production

  int resendCountdown = 0;
  Timer? _timer;

  void startResendTimer() {
    resendCountdown = 60;
    notifyListeners();

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown == 0) {
        timer.cancel();
      } else {
        resendCountdown--;
        notifyListeners();
      }
    });
  }

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resendCode(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send_reset_code.php"),
        body: jsonEncode({"email": email}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": isEnglish ? "Network error" : "Ralat rangkaian"
      };
    }
  }

  Future<Map<String, dynamic>> sendCode(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/send_reset_code.php"),
        body: jsonEncode({"email": email}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": isEnglish ? "Network error" : "Ralat rangkaian"
      };
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/verify_code.php"),
        body: jsonEncode({"email": email, "code": code}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": isEnglish ? "Network error" : "Ralat rangkaian"
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String password) async {
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$')
        .hasMatch(password)) {
      return {
        "status": "error",
        "message": isEnglish
            ? "Password do not meet the requirements"
            : "Kata laluan tidak memenuhi syarat"
      };
    }

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/reset_password.php"),
        body: jsonEncode({"email": email, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": isEnglish ? "Network error" : "Ralat rangkaian"
      };
    }
  }
}
import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Changepasswordcontroller extends ChangeNotifier {
  final String baseUrl = MyConfig.myurl; 

  bool isLoading = false;
  bool isEnglish = true;

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      notifyListeners();
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  // STEP 1: VERIFY CURRENT PASSWORD
  Future<Map<String, dynamic>> verifyCurrentPassword(String password) async {
    isLoading = true;
    notifyListeners();

    final userId = await getUserId();

    final response = await http.post(
      Uri.parse("$baseUrl/verify_password.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "current_password": password,
      }),
    );

    isLoading = false;
    notifyListeners();

    return jsonDecode(response.body);
  }

  // STEP 2: UPDATE PASSWORD
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(newPassword)) {
      return {
        "status": "error",
        "message": isEnglish
            ? "Please enter a valid password"
            : "Sila masukkan kata laluan yang sah"
      };
    }

    isLoading = true;
    notifyListeners();

    final userId = await getUserId();

    final response = await http.post(
      Uri.parse("$baseUrl/update_password.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "new_password": newPassword,
      }),
    );

    isLoading = false;
    notifyListeners();

    return jsonDecode(response.body);
  }
}
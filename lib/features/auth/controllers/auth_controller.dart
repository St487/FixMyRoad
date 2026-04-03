import 'dart:convert';

import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  final String baseUrl = MyConfig.myurl; 
  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginPassword = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  TextEditingController registerEmail = TextEditingController();TextEditingController verificationCode = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController postalCode = TextEditingController();

  String? state;
  String? city;

  //============================
  //          LOGIN
  //============================
  Future<void> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();

    bool? savedRemember = prefs.getBool("remember_me");

    if (savedRemember == true) {
      loginEmail.text = prefs.getString("email") ?? "";
      loginPassword.text = prefs.getString("password") ?? "";
      rememberMe = true;
    }

    notifyListeners();
  }

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    if (loginEmail.text.isEmpty || loginPassword.text.isEmpty) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": loginEmail.text.trim(),
          "password": loginPassword.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();

        // ✅ Save user_id
        await prefs.setInt("user_id", data['user_id']);

        // ✅ Save remember me
        await prefs.setBool("remember_me", rememberMe);

        if (rememberMe) {
          await prefs.setString("email", loginEmail.text.trim());
          await prefs.setString("password", loginPassword.text.trim());
        } else {
          prefs.remove("email");
          prefs.remove("password");
        }

        isLoading = false;
        notifyListeners();
        return true;
      }

      isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }


  //============================
  //         REGISTER
  //============================
  Future<Map<String, dynamic>> register() async {
    if (registerEmail.text.isEmpty ||
        verificationCode.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      return {"status": "error", "message": "Please fill in all fields"};
    }  

    if (!RegExp(r'^(?:\+60|0)1[0-9]\d{7,8}$').hasMatch(phone.text)) {
      return {"status": "error", "message": "Please enter a valid phone number"};
    }

    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regExp = RegExp(emailPattern);
    if (!regExp.hasMatch(registerEmail.text)) {
      return {"status": "error", "message": "Please enter a valid email"};
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(password.text)) {
      return {"status": "error", "message": "Please enter a valid password"};
    }

    if (password.text != confirmPassword.text) {
      return {"status": "error", "message": "Password do not match"};
    }

    if (!RegExp(r'^\d{4}$').hasMatch(verificationCode.text)) {
      return {"status": "error", "message": "Incorrect verification code"};
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": registerEmail.text.toLowerCase().trim(),
          "phone_no": phone.text.trim(),
          "password": password.text.trim(),
          "verification_code": verificationCode.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("user_id", data['user_id']);
    }

    return data;
    } catch (e) {
      return {"status": "error", "message": "An error have occur, please try again later."};
    }
  }


  //============================
  //     COMPLETE PROFILE
  //============================
  void updateState(String? value) {
    state = value;
    city = null;
    notifyListeners();
  }

  void updateCity(String? value) {
    city = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> completeProfile() async {
  if (firstName.text.isEmpty ||
      lastName.text.isEmpty ||
      address.text.isEmpty ||
      postalCode.text.isEmpty ||
      state == null ||
      city == null) {
    return {"status": "error", "message": "Please complete all fields"};
  }

  if (!RegExp(r'^\d{5}$').hasMatch(postalCode.text)) {
    return {"status": "error", "message": "Please enter a valid postal code"};
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId == null) {
      return {"status": "error", "message": "User not found. Please login again."};
    }
    
    final response = await http.post(
      Uri.parse("$baseUrl/complete_profile.php"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "user_id": userId,
        "first_name": firstName.text.trim(),
        "last_name": lastName.text.trim(),
        "address": address.text.trim(),
        "postal_code": postalCode.text.trim(),
        "state": state,
        "city": city,
      }),
    );

    final data = json.decode(response.body);

    return data;
  } catch (e) {
    return {"status": "error", "message": "An error have occur, please try again later."};
  }
}

  void clearAll() {
    loginEmail.clear();
    loginPassword.clear();
    registerEmail.clear();
    verificationCode.clear();
    phone.clear();
    password.clear();
    confirmPassword.clear();
    firstName.clear();
    lastName.clear();
    address.clear();
    postalCode.clear();
    state = null;
    city = null;
  }
}
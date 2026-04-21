import 'dart:async';
import 'dart:convert';

import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  int countdown = 0;
  Timer? timer;

  void startCountdown() {
    timer?.cancel(); // prevent duplicate timers

    countdown = 60; // 🔥 change to 60 seconds
    notifyListeners();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
      } else {
        countdown--;
        notifyListeners();
      }
    });
  }

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
  bool isEnglish = true;
  bool mockVerification = true; // set false in production
  String? state;
  String? city;

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      notifyListeners();
    }
  }

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

  Future<Map<String, dynamic>> login() async {
    isLoading = true;
    notifyListeners();

    if (loginEmail.text.isEmpty || loginPassword.text.isEmpty) {
      isLoading = false;
      notifyListeners();
      return {
        "success": false,
        "message": isEnglish ? "Email and Password Cannot Be Empty" : "Emel dan Kata Laluan Tidak Boleh Dikosongkan",
      };
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

        await prefs.setInt("user_id", data['user_id']);
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

        return {
          "success": true,
          "message": isEnglish ? "Login Successful" : "Berjaya Log Masuk",
          "user_id": data['user_id'],
        };
      }

      // Login failed
      isLoading = false;
      notifyListeners();
      return {
        "success": false,
        "message": data['message'] ?? (isEnglish 
          ? "Wrong Email or Password" 
          : "Emel atau Kata Laluan Salah"),
      };
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {
        "success": false,
        "message": isEnglish ? "Something went wrong. Please Try Again Later" : "Ralat Berlaku. Sila Cuba Sebentar Lagi",
      };
    }
  }


  //============================
  //         REGISTER
  //============================
  Future<Map<String, dynamic>> register() async {
    isLoading = true;
    if (registerEmail.text.isEmpty ||
        verificationCode.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Please fill in all fields" : "Sila isi semua ruang kosong",};
    }  

    if (!RegExp(r'^(?:\+60|0)1[0-9]\d{7,8}$').hasMatch(phone.text)) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Please enter a valid phone number" : "Sila masukkan nombor telefon yang sah"};
    }

    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regExp = RegExp(emailPattern);
    if (!regExp.hasMatch(registerEmail.text)) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Please enter a valid email" : "Sila masukkan emel yang sah"};
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(password.text)) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Please enter a valid password" : "Sila masukkan kata laluan yang sah"};
    }

    if (password.text != confirmPassword.text) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Password do not match" : "Kata laluan tidak sepadan"};
    }

    // if (!RegExp(r'^\d{4}$').hasMatch(verificationCode.text)) {
    //   return {"status": "error", "message": isEnglish ? "Incorrect verification code" : "Kod pengesahan salah"};
    // }

    final code = verificationCode.text.trim();

    if (!mockVerification) {
      if (!RegExp(r'^\d{4}$').hasMatch(code)) {
        return {
          "status": "error",
          "message": isEnglish ? "Incorrect verification code" : "Kod pengesahan salah"
        };
      }
    } else {
      if (code != "1234") {
        return {
          "status": "error",
          "message": isEnglish
              ? "Incorrect verification code (Mock: 1234)"
              : "Kod salah (Mock: 1234)"
        };
      }
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

      isLoading = false;

      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("user_id", data['user_id']);
      }

    return data;
    } catch (e) {
      isLoading = false;
      return {"status": "error", "message": isEnglish ? "Something went wrong. Please try again later" : 'Sila cuba sebentar lagi'};
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode() async {
    isLoading = true;
    if (registerEmail.text.isEmpty) {
      isLoading = false;
      return {
        "status": "error",
        "message": isEnglish ? "Enter email first" : "Sila masukkan emel dahulu"
      };
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send_code.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": registerEmail.text.trim(),
        }),
      );

      isLoading = false;

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      isLoading = false;
      return {
        "status": "error",
        "message": isEnglish
            ? "Failed to send code"
            : "Gagal menghantar kod"
      };
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
    isLoading = true;
  if (firstName.text.isEmpty ||
      lastName.text.isEmpty ||
      address.text.isEmpty ||
      postalCode.text.isEmpty ||
      state == null ||
      city == null) {
    isLoading = false;
    return {"status": "error", "message": isEnglish ? "Please fill in all fields" : "Sila isi semua ruang kosong"};
  }

  if (!RegExp(r'^\d{5}$').hasMatch(postalCode.text)) {
    isLoading = false;
    return {"status": "error", "message": isEnglish ? "Please enter a valid postal code" : "Sila masukkan poskod yang sah"};
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("user_id");

    if (userId == null) {
      return {"status": "error", "message": isEnglish ? "User not found. Please login again." : "Pengguna tidak ditemui. Sila log masuk semula."};
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
    isLoading = false;
    final data = json.decode(response.body);

    return data;
  } catch (e) {
    isLoading = false;
    return {"status": "error", "message": isEnglish ? 'Something went wrong. Please try again later' : 'Sila cuba sebentar lagi'};
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
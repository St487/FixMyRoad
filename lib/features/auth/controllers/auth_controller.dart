import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  TextEditingController loginEmail = TextEditingController();
  TextEditingController loginPassword = TextEditingController();

  bool isLoading = false;

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

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    //await Future.delayed(const Duration(seconds: 1));

    if (loginEmail.text.isEmpty || loginPassword.text.isEmpty) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    if (loginEmail.text == "admin@gmail.com" &&
        loginPassword.text == "123456") {
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String> register() async {
    if (registerEmail.text.isEmpty ||
        verificationCode.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      return "Please fill all fields";
    }

    if (!RegExp(r'^(?:\+60|0)1[0-9]\d{7,8}$').hasMatch(phone.text)) {
      return "Please enter a valid phone number";
    }

    String emailPattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regExp = RegExp(emailPattern);
    if (!regExp.hasMatch(registerEmail.text)) {
      return "Please enter a valid email";
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(password.text)) {
      return "Password must be match the format";
    }

    if (password.text != confirmPassword.text) {
      return "Passwords do not match";
    }

    if (!RegExp(r'^\d{4}$').hasMatch(verificationCode.text)) {
      return "Verification code must be 4 digits";
    }

    return "success";
  }

  void updateState(String? value) {
    state = value;
    city = null;
    notifyListeners();
  }

  void updateCity(String? value) {
    city = value;
    notifyListeners();
  }

  Future<String> completeProfile() async {
  if (firstName.text.isEmpty ||
      lastName.text.isEmpty ||
      address.text.isEmpty ||
      postalCode.text.isEmpty ||
      state == null ||
      city == null) {
    return "Please complete all fields";
  }

  if (!RegExp(r'^\d{5}$').hasMatch(postalCode.text)) {
    return "Postal code must be 5 digits";
  }

  return "success";
}

  void clearProfileFields() {
    firstName.clear();
    lastName.clear();
    address.clear();
    postalCode.clear();
    state = null;
    city = null;
    notifyListeners();
  }

  void clearRegistrationFields() {
    registerEmail.clear();
    verificationCode.clear();
    phone.clear();
    password.clear();
    confirmPassword.clear();
  }

  void clearAll() {
    loginEmail.clear();
    loginPassword.clear();
    registerEmail.clear();
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
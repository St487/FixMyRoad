import 'dart:io';

import 'package:fix_my_road/features/auth/service/location_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fix_my_road/utils/myconfig.dart';

class ProfileController extends ChangeNotifier {

  final String baseUrl = MyConfig.myurl; 
  String firstName = "";
  String lastName = "";
  String email = "";
  String? phone;
  String? address;
  String? postalCode;
  String? state;
  String? city;
  String? selectedCity;
  String? profilePicture;
  bool isProfileLoading = false;

  Future<void> getProfile() async {
    isProfileLoading = true;
    notifyListeners();

    try {
      // await Future.delayed(const Duration(seconds: 3));
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("user_id");

      if (userId == null) {
        isProfileLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/get_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "user_id": userId,
        }),
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final user = data['data'];

        firstName = user['first_name'] ?? "";
        lastName = user['last_name'] ?? "";
        email = user['email'] ?? "";
        phone = user['phone'] ?? "";
        address = user['address'] ?? "";
        postalCode = user['postal_code'] ?? "";
        state = user['state'] ?? "";
        city = user['city'] ?? "";
        profilePicture = user['profile_picture'] ?? null;


        selectedCity = user['city'] ?? "";
  
      } else {
        firstName = "";
        lastName = "";
        email = "";
        profilePicture = null;
      }

    } catch (e) {
      firstName = "";
      lastName = "";
      email = "";
      profilePicture = null;
    }

    isProfileLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt("user_id");

      if (userId == null) {
        return {"status": "error", "message": "User not logged in"};
      }

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/get_profile.php"),
      );

      request.fields['user_id'] = userId.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        ),
      );

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      return json.decode(res.body);

    } catch (e) {
      return {"status": "error", "message": "Upload failed"};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? address,
    String? postalCode,
    String? state,
    String? city,
    File? profileImage,
  }) async {
    try {
      isProfileLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id'); // Make sure user_id is saved on login

      if (userId == null) {
        isProfileLoading = false;
        notifyListeners();
        return {"status": "error", "message": "User ID missing"};
      }

      var uri = Uri.parse("${MyConfig.myurl}/update_profile.php");
      var request = http.MultipartRequest("POST", uri);

      // Add text fields
      request.fields['user_id'] = userId.toString();
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['email'] = email;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;
      if (postalCode != null) request.fields['postal_code'] = postalCode;
      if (state != null) request.fields['state'] = state;
      if (city != null) request.fields['city'] = city;

      // Add profile image if exists
      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image', profileImage.path,
        ));
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      isProfileLoading = false;
      notifyListeners();

      // Parse backend response
      if (respStr.isNotEmpty) {
        final data = jsonDecode(respStr);
        // Update local variables if needed
        this.firstName = data['first_name'] ?? this.firstName;
this.lastName = data['last_name'] ?? this.lastName;
this.email = data['email'] ?? this.email;
this.phone = data['phone'] ?? this.phone;
this.address = data['address'] ?? this.address;
this.postalCode = data['postal_code'] ?? this.postalCode;
this.state = data['state'] ?? this.state;
this.city = data['city'] ?? this.city;
this.profilePicture = data['profile_picture'] ?? this.profilePicture;

        notifyListeners();
        return {"status": "success", "message": data['message'] ?? "Profile updated"};
      } else {
        return {"status": response.statusCode == 200 ? "success" : "error", "message": "Profile updated"};
      }
    } catch (e) {
      isProfileLoading = false;
      notifyListeners();
      return {"status": "error", "message": e.toString()};
    }
  }
}
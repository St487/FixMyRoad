import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fix_my_road/utils/myconfig.dart';

class HomeController extends ChangeNotifier {
  bool _disposed = false;
  String greeting = "Hello";
  String firstName = "User";
  List<Map<String, dynamic>> nearbyIssues = [];
  bool locationPermissionDenied = false;
  String? errorMessage; // Store error messages for UI

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // Set greeting based on current time
  void setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 18) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }
    notifyListeners();
  }

  // Set first name from full name
  void setUserFirstName(String name) {
    if (name.contains(" ")) {
      firstName = name.split(" ")[0];
    } else {
      firstName = name;
    }
    notifyListeners();
  }

  // Fetch nearby issues based on location and user ID
  Future<void> fetchNearbyIssues(String userId) async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        locationPermissionDenied = true;
        errorMessage = "Location permission denied.";
        notifyListeners();
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/home.php"),
        body: {
          "user_id": userId,
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
        },
      );// Debugging line to check the response from the server

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          nearbyIssues = List<Map<String, dynamic>>.from(data['issues']);
        } else {
          errorMessage = data['message'] ?? "Failed to fetch nearby issues.";
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Error fetching nearby issues: $e";
    }

    notifyListeners();
  }

  // Fetch user profile from get profile PHP endpoint
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      errorMessage = "User ID not found. Please login again.";
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/get_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "user_id": userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final userData = data['data'];
          setUserFirstName(userData['first_name'] ?? "User");
        } else {
          errorMessage = data['message'] ?? "Failed to fetch user profile.";
        }
      } else {
        errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Error fetching user profile: $e";
      firstName = "User";
      notifyListeners();
    }
  }

  Future<void> initUserData() async {
    setGreeting();

    await fetchUserProfile();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id")?.toString() ?? "";

    if (userId.isNotEmpty) {
      await fetchNearbyIssues(userId);
    }
  }
}
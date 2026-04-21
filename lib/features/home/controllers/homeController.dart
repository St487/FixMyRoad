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
  bool isEnglish = true;

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      setGreeting(); // Refresh the greeting text in the new language
      notifyListeners();
    }
  }

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

  void setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = isEnglish ? "Good Morning" : "Selamat Pagi";
    } else if (hour < 18) {
      greeting = isEnglish ? "Good Afternoon" : "Selamat Petang";
    } else {
      greeting = isEnglish ? "Good Evening" : "Selamat Malam";
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
    locationPermissionDenied = false;
    errorMessage = null;

    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        locationPermissionDenied = true;
        errorMessage = isEnglish ? "Location permission denied." : "Izin lokasi ditolak.`";
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
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          nearbyIssues = List<Map<String, dynamic>>.from(data['issues']);
        } else {
          errorMessage = data['message'] ?? isEnglish ? "Failed to fetch nearby issues." : "Gagal mengambil masalah terdekat.";
          nearbyIssues = [];
        }
      } else {
        errorMessage = isEnglish ? "Server error: ${response.statusCode}" : "Kesalahan server: ${response.statusCode}";
        nearbyIssues = [];
      }
    } catch (e) {
      errorMessage = isEnglish ? "Error fetching nearby issues: $e" : "Kesalahan mengambil masalah terdekat: $e";
      nearbyIssues = [];
    }

    notifyListeners();
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      errorMessage = isEnglish ? "User ID not found. Please login again." : "ID pengguna tidak ditemukan. Silakan login lagi.";
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/get_profile.php"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final userData = data['data'];
          setUserFirstName(userData['first_name'] ?? "User");
        } else {
          errorMessage = data['message'] ?? isEnglish ? "Failed to fetch user profile." : "Gagal mengambil profil pengguna.";
        }
      } else {
        errorMessage = isEnglish ? "Server error: ${response.statusCode}" : "Kesalahan server: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = isEnglish ? "Error fetching user profile: $e" : "Kesalahan mengambil profil pengguna: $e";
      firstName = "User";
      notifyListeners();
    }
  }

  // Initialize all user data
  Future<void> initUserData() async {
    setGreeting();
    await fetchUserProfile();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id")?.toString() ?? "";

    if (userId.isNotEmpty) {
      await fetchNearbyIssues(userId);
    }
  }

  // Filtered issues for UI
  List<Map<String, dynamic>> get filteredNearbyIssues {
    return nearbyIssues
        .where((issue) =>
            issue['status'] == 'approved' || issue['status'] == 'in_progress')
        .toList();
  }
}
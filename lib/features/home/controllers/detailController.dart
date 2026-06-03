import 'package:fix_my_road/utils/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';

class DetailController extends ChangeNotifier {
  final int issueId;

  DetailController({required this.issueId});

  Map<String, dynamic>? issue;
  bool isLoading = true;
  int currentImageIndex = 0;
  String? errorMessage;
  bool isEnglish = true;

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      notifyListeners();
    }
  }

  // Initialize controller
  Future<void> init() async {
    await fetchIssue();
  }

  // Fetch issue details from API
  Future<void> fetchIssue() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse("${MyConfig.myurl}/get_nearby_issues.php?id=$issueId");
      final response = await http.get(url);

      print("Fetch Issue Response: ${response.body}"); // Debugging line

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          issue = data['data'];
        } else {
          errorMessage = data['message'] ?? isEnglish ? "Failed to fetch issues" : "Gagal mendapatkan isu";
        }
      } else {
        errorMessage = isEnglish ? "Failed to fetch issues" : "Gagal mendapatkan isu";
      }
    } catch (e) {
      errorMessage = isEnglish ? "Failed to fetch issues" : "Gagal mendapatkan isu";
    }

    isLoading = false;
    notifyListeners();
  }

  List<String> get photos {
    if (issue == null) return [];

    List<String?> raw = [
      issue!['photo1'],
      issue!['photo2'],
      issue!['photo3'],
    ];

    return raw
        .where((p) => p != null && p.toString().isNotEmpty)
        .map((p) => ImageHelper.getUrl(p))
        .toList();
  }

  void setCurrentImageIndex(int index) {
    currentImageIndex = index;
    notifyListeners();
  }
}
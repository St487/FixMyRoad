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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          issue = data['data'];
        } else {
          errorMessage = data['message'] ?? "Failed to fetch issue";
        }
      } else {
        errorMessage = "HTTP Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  // Get photos list
  List<String> get photos {
    if (issue == null) return [];
    final List<String> list = [];
    if (issue!['photo1'] != null) list.add(issue!['photo1']);
    if (issue!['photo2'] != null) list.add(issue!['photo2']);
    if (issue!['photo3'] != null) list.add(issue!['photo3']);
    return list;
  }

  void setCurrentImageIndex(int index) {
    currentImageIndex = index;
    notifyListeners();
  }
}
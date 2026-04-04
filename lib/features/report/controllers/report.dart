import 'dart:io';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';

class ReportController extends ChangeNotifier {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? selectedType;
  LatLng? pickedLocation;
  String? pickedAddress;
  List<File> selectedImages = [];

  List<Map<String, dynamic>> reports = [];
  List<String> existingPhotos = []; // ✅ ADD THIS

  bool isSubmitting = false;

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedType = null;
    pickedLocation = null;
    pickedAddress = null;
    selectedImages = [];
    notifyListeners();
  }

  String? validateFields() {
    if (selectedType == null || selectedType!.trim().isEmpty) return "Please select type of issue.";
    if (titleController.text.trim().isEmpty) return "Please enter title.";
    if (descriptionController.text.trim().isEmpty) return "Please enter description.";
    if (pickedLocation == null || pickedAddress == null) return "Please pick a location.";
    return null;
  }

  Future<bool> submitReport(int userId) async {
    final error = validateFields();
    if (error != null) return Future.error(error);

    isSubmitting = true;
    notifyListeners();

    try {
      var uri = Uri.parse("${MyConfig.myurl}/add_report.php");
      var request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId.toString();
      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['type'] = selectedType!; 
      request.fields['address'] = pickedAddress!;
      request.fields['latitude'] = pickedLocation!.latitude.toString();
      request.fields['longitude'] = pickedLocation!.longitude.toString();

      // Send existing photos (IMPORTANT)
      for (int i = 0; i < existingPhotos.length; i++) {
        request.fields['existing_photos[]'] = existingPhotos[i];
      }

      // Add new images
      for (int i = 0; i < selectedImages.length && i < 3; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]',
          selectedImages[i].path,
        ));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);

      isSubmitting = false;
      notifyListeners();

      if (data['status'] == 'success') {
        clearForm();
        return true;
      } else {
        return Future.error(data['message'] ?? "Submission failed");
      }
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      return Future.error("Error submitting report: $e");
    }
  }
  
  Future<void> getReports(int userId) async {
    try {
      var url = Uri.parse("${MyConfig.myurl}/get_report.php?user_id=$userId");

      var response = await http.get(url);
      var data = json.decode(response.body);

      if (data['status'] == 'success') {
        reports = List<Map<String, dynamic>>.from(data['data']).map((report) {

      // ✅ FIX ID TYPE HERE (IMPORTANT)
      if (report['id'] is String) {
        report['id'] = int.tryParse(report['id']) ?? 0;
      }

        if (report['photos'] != null) {
          List<String> photoUrls = [];
          for (var photo in report['photos']) {
            if (photo != null && photo.toString().isNotEmpty) {
              photoUrls.add("${MyConfig.myurl}/$photo");
            }
          }
          report['photos'] = photoUrls;
        } else {
          report['photos'] = [];
        }
        return report;
      }).toList();
      notifyListeners();
      } else {
        throw data['message'] ?? "Failed to fetch reports";
      }
    } catch (e) {
      throw "Error fetching reports: $e";
    }
  }

  Future<bool> updateReport(int reportId, int userId) async {
  final error = validateFields();
    if (error != null) return Future.error(error);

    isSubmitting = true;
    notifyListeners();

    try {
      var uri = Uri.parse("${MyConfig.myurl}/update_report.php");
      var request = http.MultipartRequest('POST', uri);

      request.fields['report_id'] = reportId.toString();
      request.fields['user_id'] = userId.toString();
      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['type'] = selectedType!;
      request.fields['address'] = pickedAddress!;
      request.fields['latitude'] = pickedLocation!.latitude.toString();
      request.fields['longitude'] = pickedLocation!.longitude.toString();

      // Add images if any
      for (int i = 0; i < selectedImages.length && i < 3; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]',
          selectedImages[i].path,
        ));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);

      isSubmitting = false;
      notifyListeners();

      if (data['status'] == 'success') {
        clearForm();
        return true;
      } else {
        return Future.error(data['message'] ?? "Update failed");
      }
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      return Future.error("Error updating report: $e");
    }
  }

  Future<Map<String, dynamic>> getReportById(int id) async {
    var url = Uri.parse("${MyConfig.myurl}/get_single_report.php?id=$id");

    var response = await http.get(url);
    var data = json.decode(response.body);

    if (data['status'] == 'success') {
      return data['data'];
    } else {
      throw data['message'];
    }
  }
  
}
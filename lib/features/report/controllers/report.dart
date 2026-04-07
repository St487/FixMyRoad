import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportController extends ChangeNotifier {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool isEnglish = true;

  String? selectedType;
  LatLng? pickedLocation;
  String? pickedAddress;

  List<File> selectedImages = [];

  List<Map<String, dynamic>> reports = [];
  List<String> existingPhotos = [];

  bool isSubmitting = false;

  void setLanguage(bool value) {
    if (isEnglish != value) {
      isEnglish = value;
      notifyListeners();
    }
  }

  Map<String, String> issueTypeMapping = {
    "Saliran / Banjir": "Drainage",
    "Lubang Jalan": "Pothole",
    "Kemudahan Pengangkutan Awam": "Public Transport Facilities",
    "Tanda Jalan": "Road Sign",
    "Keselamatan tepi jalan": "Roadside Safety",
    "Lampu Jalan": "Street Light",
    "Lampu Isyarat": "Traffic Light",
    "Lain-lain": "Other",
  };

  Map<String, String> malayToEnglish = {
    "Saliran / Banjir": "Drainage",
    "Lubang Jalan": "Pothole",
    "Kemudahan Pengangkutan Awam": "Public Transport Facilities",
    "Tanda Jalan": "Road Sign",
    "Keselamatan Tepi Jalan": "Roadside Safety",
    "Lampu Jalan": "Street Light",
    "Lampu Isyarat": "Traffic Light",
    "Lain-lain": "Other",
  };

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    selectedType = null;
    pickedLocation = null;
    pickedAddress = null;
    selectedImages.clear();
    existingPhotos.clear();
    notifyListeners();
  }

  String? validateFields() {
    if (selectedType == null || selectedType!.trim().isEmpty) return isEnglish ? "Please Select Type of Issue" : "Sila Pilih Jenis Masalah";
    if (titleController.text.trim().isEmpty) return isEnglish ? "Please Enter Title" : "Sila Isi Tajuk";
    if (descriptionController.text.trim().isEmpty) return isEnglish ? "Please Enter Description" : "Sila Isi Deskripsi";
    if (pickedLocation == null || pickedAddress == null) return isEnglish ? "Please Pick a Location" : "Sila Pilih Lokasi";
    if (existingPhotos.isEmpty && selectedImages.isEmpty) return isEnglish ? "At least one photo is required" : "Sekurang-kurangnya satu gambar diperlukan.";
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
        return Future.error(data['message'] ?? isEnglish ? "Submission Failed" : "Gagal untuk Hantar Laporan");
      }
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      return Future.error(isEnglish ? "Error Submission, Please Try Again Later" : "Gagal untuk Hantar Laporan, Sila Cuba Sebentar Lagi");
    }
  }
  
  Future<void> getReports(int userId) async {
    try {
      var url = Uri.parse("${MyConfig.myurl}/get_report.php?user_id=$userId");

      var response = await http.get(url);
      var data = json.decode(response.body);

      if (data['status'] == 'success') {
        reports = List<Map<String, dynamic>>.from(data['data']).map((report) {

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
        throw data['message'] ?? isEnglish ? "Failed to Fetch Reports" : "Gagal untuk Mendapatkan Laporan";
      }
    } catch (e) {
      throw isEnglish ? "Error to Fetch Reports" : "Gagal untuk Mendapatkan Laporan";
    }
  }

  Future<bool> updateReport(int reportId, int userId) async {
  final error = validateFields();
    if (error != null) return Future.error(isEnglish ? "All required fields must be filled." : "Semua ruangan mesti diisi.");

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

      for (int i = 0; i < existingPhotos.length; i++) {
        request.fields['existing_photos[$i]'] = existingPhotos[i];
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
        return Future.error(data['message'] ?? isEnglish ? "Update Failed" : "Gagal untuk Kemas Kini");
      }
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      return Future.error(isEnglish ? "Error. Update Failed" : "Gagal untuk Kemas Kini");
    }
  }

  Future<Map<String, dynamic>> getReportById(int id) async {
    var url = Uri.parse("${MyConfig.myurl}/get_single_report.php?id=$id");

    var response = await http.get(url);
    var data = json.decode(response.body);

    if (data['status'] == 'success') {
      return data['data'];
    } else {
      throw data[isEnglish ? "Report Not Found" : "Laporan Tidak Ditemui"];
    }
  }

  Future<void> loadReportDetails(int reportId, bool isEnglish, List<String> issueTypes) async {
    final data = await getReportById(reportId);

    String? matchDropdown(List<String> list, String value) {
      try {
        return list.firstWhere((e) => e.toLowerCase() == value.toLowerCase());
      } catch (e) {
        return null;
      }
    }

    titleController.text = data['title'] ?? '';
    descriptionController.text = data['description'] ?? '';
    locationController.text = data['location_text'] ?? '';
    pickedAddress = data['location_text'];

    String? apiIssueType = data['issue_type']?.trim();
    if (apiIssueType != null) {
      if (isEnglish) {
        selectedType = matchDropdown(issueTypes, apiIssueType);
      } else {
        final englishToMalay = issueTypeMapping.map((k, v) => MapEntry(v.toLowerCase(), k));
        String? malayValue = englishToMalay[apiIssueType.toLowerCase()];
        if (malayValue != null) selectedType = matchDropdown(issueTypes, malayValue);
      }
    }

    final lat = double.tryParse(data['latitude'].toString());
    final lng = double.tryParse(data['longitude'].toString());
    if (lat != null && lng != null) {
      pickedLocation = LatLng(lat, lng);
    }

    existingPhotos = List<String>.from(data['photos'] ?? [])
        .map((photo) => "${MyConfig.myurl}/$photo")
        .toList();
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic id = prefs.get('user_id');
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }
  
}
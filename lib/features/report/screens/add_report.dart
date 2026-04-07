import 'package:fix_my_road/features/map/screens/map_picker_page.dart';
import 'package:fix_my_road/features/report/controllers/reportController.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  GoogleMapController? _mapController;
  String? selectedType;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // LOGIC PRESERVED: Camera/Gallery Picking
  Future<void> _pickFromCamera() async {
    final report = context.read<ReportController>();
    if (report.selectedImages.length >= 3) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() => report.selectedImages.add(File(image.path)));
    }
  }

  Future<void> _pickFromGallery(bool lang) async {
    final report = context.read<ReportController>();
    int remainingSlots = 3 - report.selectedImages.length;
    if (remainingSlots <= 0) return;
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() {
        final List<XFile> selectedLimit = images.take(remainingSlots).toList();
        for (var image in selectedLimit) {
          report.selectedImages.add(File(image.path));
        }
      });
      if (images.length > remainingSlots) {
        CustomSnackbar.show(context, AppText.maxImagesWarning(lang, remainingSlots), Colors.redAccent, Colors.white);
      }
    }
  }

  // Reusable Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.withOpacity(0.7),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // Custom Input Decoration
  InputDecoration _inputStyle(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple, width: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportController>();
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;
    final List<String> issueTypes = AppText.getList(lang);

    const kBackground = Color(0xFFF8F9FD); // Clean off-white
    const kPrimary = Colors.deepPurple;

    WidgetsBinding.instance.addPostFrameCallback((_) => report.setLanguage(lang));

    return WillPopScope(
      onWillPop: () async {
        report.clearForm();
        return true;
      },
      child: Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () {
              report.clearForm();
              Navigator.pop(context);
            },
          ),
          title: Text(
            AppText.addReport(lang),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // INFO CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(AppText.reportType(lang)),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.unfold_more_rounded, color: Colors.grey),
                        style: const TextStyle(fontSize: 15, color: Colors.black),
                        items: issueTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedType = v;
                            report.selectedType = lang ? v : (report.malayToEnglish[v!] ?? v);
                          });
                        },
                        decoration: _inputStyle(AppText.selectType(lang)),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader(AppText.title(lang)),
                      TextField(
                        controller: report.titleController,
                        decoration: _inputStyle(AppText.inputTitle(lang)),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader(AppText.description(lang)),
                      TextField(
                        maxLines: 3,
                        controller: report.descriptionController,
                        decoration: _inputStyle(AppText.inputDescription(lang)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LOCATION CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(AppText.location(lang)),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: report.pickedAddress ?? ''),
                        decoration: _inputStyle(
                          AppText.selectLocation(lang),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (report.pickedLocation != null)
                                IconButton(icon: const Icon(Icons.cancel, color: Colors.grey), onPressed: () => setState(() { report.pickedLocation = null; report.pickedAddress = null; })),
                              IconButton(
                                icon: const Icon(Icons.map_rounded, color: kPrimary),
                                onPressed: () async {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPickerPage()));
                                  if (result != null && result is Map) {
                                    setState(() {
                                      report.pickedLocation = result["position"] as LatLng;
                                      report.pickedAddress = result["address"] as String;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (report.pickedLocation != null) ...[
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 150,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(target: report.pickedLocation!, zoom: 15),
                              onMapCreated: (controller) => _mapController = controller,
                              zoomControlsEnabled: false,
                              markers: {Marker(markerId: const MarkerId("loc"), position: report.pickedLocation!)},
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // PHOTOS SECTION
                _buildSectionHeader("${AppText.photos(lang)} (${report.selectedImages.length}/3)"),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: report.selectedImages.length + (report.selectedImages.length < 3 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == report.selectedImages.length) {
                        return GestureDetector(
                          onTap: () => _showPickerOptions(lang),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.deepPurple.withOpacity(0.2), style: BorderStyle.solid),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.deepPurple),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(image: FileImage(report.selectedImages[index]), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 17,
                            child: GestureDetector(
                              onTap: () => setState(() => report.selectedImages.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final error = report.validateFields();
                      if (error != null) {
                        CustomSnackbar.show(context, error, Colors.redAccent, Colors.white);
                        return;
                      }
                      final userId = await _getUserId();
                      if (userId == null) return;
                      bool success = await report.submitReport(userId);
                      if (success) {
                        CustomSnackbar.show(context, AppText.submitReportSuccess(lang), Colors.green, Colors.white);
                        report.clearForm();
                        setState(() => selectedType = null);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: Text(
                      AppText.submitReport(lang),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPickerOptions(bool lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Source", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(Icons.camera_alt_rounded, AppText.takePhoto(lang), _pickFromCamera),
                _sourceOption(Icons.image_rounded, AppText.chooseGallery(lang), () => _pickFromGallery(lang)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption(IconData icon, String label, Function onTap) {
    return GestureDetector(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.deepPurple.withOpacity(0.1), child: Icon(icon, color: Colors.deepPurple)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
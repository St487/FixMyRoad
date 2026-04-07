// ignore_for_file: use_build_context_synchronously

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
import 'package:fix_my_road/utils/myconfig.dart';

class EditReport extends StatefulWidget {
  final int reportId;
  const EditReport({super.key, required this.reportId});

  @override
  State<EditReport> createState() => _EditReportState();
}

class _EditReportState extends State<EditReport> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;

  List<String> _initialPhotoUrls = [];
  final List<File> _selectedImages = [];
  String? _pickedAddress;
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  String? selectedType;
  String? selectedTypeMalay;
  String? selectedTypeEnglish;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    _loadReportDetails();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // --- LOGIC SECTION (PRESERVED) ---

  Future<void> _loadReportDetails() async {
    final controller = context.read<ReportController>();
    final data = await controller.getReportById(widget.reportId);
    final bool isEnglish = context.read<LanguageProvider>().isEnglish;

    if (!mounted) return;

    setState(() {
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      locationController.text = data['location_text'] ?? '';
      _pickedAddress = data['location_text'];

      final lat = double.tryParse(data['latitude'].toString());
      final lng = double.tryParse(data['longitude'].toString());
      if (lat != null && lng != null) _pickedLocation = LatLng(lat, lng);

      String? apiType = data['issue_type']?.trim();
      if (apiType != null) {
        final match = AppText.types.values.firstWhere(
          (e) => e['en']!.toLowerCase() == apiType.toLowerCase() ||
                 e['ms']!.toLowerCase() == apiType.toLowerCase(),
          orElse: () => {},
        );

        if (match.isNotEmpty) {
          selectedType = isEnglish ? match['en'] : match['ms'];
          selectedTypeEnglish = match['en'];
          selectedTypeMalay = match['ms'];
        }
      }

      _initialPhotoUrls = List<String>.from(data['photos'] ?? [])
          .map((photo) => "${MyConfig.myurl}/$photo")
          .toList();
    });
  }

  Future<void> _pickFromCamera(bool lang) async {
    int remainingSlots = 3 - (_initialPhotoUrls.length + _selectedImages.length);
    if (remainingSlots <= 0) {
      CustomSnackbar.show(context, AppText.maxUpload(lang), Colors.redAccent, Colors.white);
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null && mounted) {
      setState(() => _selectedImages.add(File(image.path)));
    }
  }

  Future<void> _pickFromGallery(bool lang) async {
    int remainingSlots = 3 - (_initialPhotoUrls.length + _selectedImages.length);
    if (remainingSlots <= 0) {
      CustomSnackbar.show(context, AppText.maxUpload(lang), Colors.redAccent, Colors.white);
      return;
    }
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty && mounted) {
      final selectedLimit = images.take(remainingSlots).toList();
      setState(() => _selectedImages.addAll(selectedLimit.map((e) => File(e.path))));
      if (images.length > remainingSlots) {
        CustomSnackbar.show(context, AppText.maxImagesWarning(lang, remainingSlots), Colors.redAccent, Colors.white);
      }
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic id = prefs.get('user_id');
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  // --- DESIGN COMPONENTS ---

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
    final lang = context.watch<LanguageProvider>().isEnglish;
    final issueTypes = AppText.getList(lang);
    final reportController = context.watch<ReportController>();

    const kBackground = Color(0xFFF8F9FD);
    const kPrimary = Colors.deepPurple;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppText.editReport(lang),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                      items: issueTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          selectedType = v;
                          if (lang) {
                            selectedTypeEnglish = v;
                            selectedTypeMalay = AppText.types.values.firstWhere((e) => e['en'] == v, orElse: () => {'ms': v})['ms'];
                          } else {
                            selectedTypeMalay = v;
                            selectedTypeEnglish = AppText.types.values.firstWhere((e) => e['ms'] == v, orElse: () => {'en': v})['en'];
                          }
                        });
                      },
                      decoration: _inputStyle(AppText.selectType(lang)),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(AppText.title(lang)),
                    TextField(
                      controller: titleController,
                      decoration: _inputStyle(AppText.inputTitle(lang)),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader(AppText.description(lang)),
                    TextField(
                      maxLines: 3,
                      controller: descriptionController,
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
                      controller: locationController,
                      decoration: _inputStyle(
                        AppText.selectLocation(lang),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_pickedLocation != null)
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey),
                                onPressed: () => setState(() {
                                  _pickedLocation = null;
                                  _pickedAddress = null;
                                  locationController.text = '';
                                }),
                              ),
                            IconButton(
                              icon: const Icon(Icons.map_rounded, color: kPrimary),
                              onPressed: () async {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPickerPage()));
                                if (result != null && result is Map && mounted) {
                                  setState(() {
                                    _pickedLocation = result["position"] as LatLng;
                                    _pickedAddress = result["address"] as String;
                                    locationController.text = _pickedAddress!;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_pickedLocation != null) ...[
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 150,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(target: _pickedLocation!, zoom: 15),
                            onMapCreated: (c) => _mapController = c,
                            zoomControlsEnabled: false,
                            markers: {Marker(markerId: const MarkerId("loc"), position: _pickedLocation!)},
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // PHOTOS CARD
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
                    _buildSectionHeader(AppText.photos(lang)),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Button
                          if ((_initialPhotoUrls.length + _selectedImages.length) < 3)
                            GestureDetector(
                              onTap: () => _showPickerOptions(lang),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200, style: BorderStyle.values[1]),
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, color: kPrimary),
                              ),
                            ),
                          // Existing Photos (Network)
                          ..._initialPhotoUrls.asMap().entries.map((entry) {
                            return _buildImageThumbnail(
                              Image.network(entry.value, fit: BoxFit.cover),
                              () => setState(() => _initialPhotoUrls.removeAt(entry.key)),
                            );
                          }),
                          // New Selected Photos (File)
                          ..._selectedImages.asMap().entries.map((entry) {
                            return _buildImageThumbnail(
                              Image.file(entry.value, fit: BoxFit.cover),
                              () => setState(() => _selectedImages.removeAt(entry.key)),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // UPDATE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _handleUpdate(lang, reportController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("Update Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(Widget child, VoidCallback onRemove) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child)),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(bool lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: Text(AppText.takePhoto(lang)), onTap: () { Navigator.pop(context); _pickFromCamera(lang); }),
            ListTile(leading: const Icon(Icons.photo_library), title: Text(AppText.chooseGallery(lang)), onTap: () { Navigator.pop(context); _pickFromGallery(lang); }),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate(bool lang, ReportController controller) async {
    // Populate controller with state data
    controller.titleController.text = titleController.text.trim();
    controller.descriptionController.text = descriptionController.text.trim();
    controller.selectedType = selectedTypeEnglish;
    controller.pickedAddress = _pickedAddress;
    controller.pickedLocation = _pickedLocation;
    controller.selectedImages = _selectedImages;
    controller.existingPhotos = _initialPhotoUrls.map((url) => url.replaceFirst("${MyConfig.myurl}/", "")).toList();

    final error = controller.validateFields();
    if (error != null) {
      CustomSnackbar.show(context, error, Colors.redAccent, Colors.white);
      return;
    }

    try {
      final userId = await _getUserId();
      if (userId == null) return;
      bool success = await controller.updateReport(widget.reportId, userId);
      if (success) {
        CustomSnackbar.show(context, AppText.updateReportSuccess(lang), Colors.greenAccent, Colors.white);
        Navigator.pop(context, true);
      }
    } catch (e) {
      CustomSnackbar.show(context, AppText.failedToUpload(lang), Colors.redAccent, Colors.white);
    }
  }
}
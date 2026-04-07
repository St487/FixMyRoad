import 'package:fix_my_road/features/map/screens/map_picker_page.dart';
import 'package:fix_my_road/features/report/controllers/report.dart';
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
  List<File> _selectedImages = [];
  String? _pickedAddress;
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  String? selectedType;
  String? selectedTypeMalay; // store the Malay text
  String? selectedTypeEnglish; // store the English text

  final ImagePicker _picker = ImagePicker();

  final Map<String, String> issueTypeMapping = {
    "Banjir": "Drainage",
    "Lubang Jalan": "Pothole",
    "Kemudahan Pengangkutan Awam": "Public Transport Facilities",
    "Tanda Jalan": "Road Sign",
    "Keselamatan tepi jalan": "Roadside Safety",
    "Lampu Jalan": "Street Light",
    "Lampu Isyarat": "Traffic Light",
    "Lain-lain": "Other",
  };

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

  Future<void> _pickFromCamera() async {
    int remainingSlots = 3 - (_initialPhotoUrls.length + _selectedImages.length);
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 photos allowed.")),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null && mounted) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    int remainingSlots = 3 - (_initialPhotoUrls.length + _selectedImages.length);
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 photos allowed.")),
      );
      return;
    }
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty && mounted) {
      final selectedLimit = images.take(remainingSlots).toList();
      setState(() {
        _selectedImages.addAll(selectedLimit.map((e) => File(e.path)));
      });
      if (images.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Only $remainingSlots images were added (Max 3 allowed)")),
        );
      }
    }
  }

  void _showPickerOptions() {
    final lang = context.read<LanguageProvider>().isEnglish;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppText.takePhoto(lang)),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppText.chooseGallery(lang)),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic id = prefs.get('user_id');
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> _loadReportDetails() async {
    final controller = context.read<ReportController>();
    final data = await controller.getReportById(widget.reportId);

    final bool isEnglish = context.read<LanguageProvider>().isEnglish;
    final List<String> currentIssueTypes = AppText.getList(isEnglish); // dropdown items

    if (!mounted) return;

    setState(() {
      // Populate text fields
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      locationController.text = data['location_text'] ?? '';
      _pickedAddress = data['location_text'];

      // Set location if available
      final lat = double.tryParse(data['latitude'].toString());
      final lng = double.tryParse(data['longitude'].toString());
      if (lat != null && lng != null) _pickedLocation = LatLng(lat, lng);

      // Map API issue_type to dropdown value
      String? apiType = data['issue_type']?.trim();
      if (apiType != null) {
        // Match both English and Malay from AppText mapping
        final match = AppText.types.values.firstWhere(
          (e) => e['en']!.toLowerCase() == apiType.toLowerCase() ||
                e['ms']!.toLowerCase() == apiType.toLowerCase(),
          orElse: () => {},
        );

        if (match.isNotEmpty) {
          selectedType = isEnglish ? match['en'] : match['ms'];
          selectedTypeEnglish = match['en']; // backend uses English
          selectedTypeMalay = match['ms'];   // optional, for UI reference
        }
      }

      // Load existing photos
      _initialPhotoUrls = List<String>.from(data['photos'] ?? [])
          .map((photo) => "${MyConfig.myurl}/$photo")
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().isEnglish;
    final issueTypes = AppText.getList(lang);

    const kBackground = Color.fromARGB(255, 247, 235, 255);
    const kGradientStart = Color.fromARGB(255, 251, 195, 226);

    final report = context.watch<ReportController>();

    return Scaffold(
    backgroundColor: kBackground,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppText.editReport(lang),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: kGradientStart,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Dropdown
              Text(AppText.reportType(lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selectedType,
                isExpanded: true,
                elevation: 4,
                items: issueTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) {
  if (v == null) return;
  
  setState(() {
    selectedType = v; // for UI display
    
    // Always convert to English for backend
    if (lang) { 
      // UI is English
      selectedTypeEnglish = v;
      selectedTypeMalay = AppText.types.values.firstWhere(
        (e) => e['en'] == v,
        orElse: () => {'ms': v},
      )['ms'];
    } else { 
      // UI is Malay
      selectedTypeMalay = v;
      selectedTypeEnglish = AppText.types.values.firstWhere(
        (e) => e['ms'] == v,
        orElse: () => {'en': v},
      )['en'];
    }

    // Save English version to controller for backend
    report.selectedType = selectedTypeEnglish;
  });
},
                decoration: InputDecoration(
                  hintText: AppText.selectType(lang),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              
              const SizedBox(height: 20),
              // Title
              Text(AppText.title(lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: AppText.inputTitle(lang),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),

              const SizedBox(height: 20),
              // Description
              Text(AppText.description(lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 5),
              TextField(
                maxLines: 4,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: AppText.inputDescription(lang),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
                const SizedBox(height: 20),
                // Location
                Text(AppText.location(lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                TextField(
                  readOnly: true,
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: AppText.selectLocation(lang),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_pickedLocation != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _pickedLocation = null;
                                _pickedAddress = null;
                                locationController.text = '';
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.location_searching_outlined),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MapPickerPage()),
                            );
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
                const SizedBox(height: 10),
                if (_pickedLocation != null)
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: _pickedLocation!, zoom: 15),
                        onMapCreated: (controller) => _mapController = controller,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        markers: {
                          Marker(markerId: const MarkerId("report_location"), position: _pickedLocation!),
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Photos
                Text(AppText.photos(lang), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: _showPickerOptions,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    child: (_initialPhotoUrls.isEmpty && _selectedImages.isEmpty)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(AppText.addPhotos(lang), style: const TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (_initialPhotoUrls.length + _selectedImages.length) < 3
                                ? _initialPhotoUrls.length + _selectedImages.length + 1
                                : 3,
                            itemBuilder: (context, index) {
                              if (index == _initialPhotoUrls.length + _selectedImages.length) {
                                return GestureDetector(
                                  onTap: _showPickerOptions,
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                                  ),
                                );
                              }

                              if (index >= _initialPhotoUrls.length) {
                                final localIndex = index - _initialPhotoUrls.length;
                                return Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: FileImage(_selectedImages[localIndex]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(localIndex);
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.black54,
                                          child: Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // Initial URL
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image: NetworkImage(_initialPhotoUrls[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _initialPhotoUrls.removeAt(index);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final controller = ReportController();
                      controller.titleController.text = titleController.text.trim();
                      controller.descriptionController.text = descriptionController.text.trim();
                      controller.selectedType = selectedTypeEnglish;
                      controller.pickedAddress = _pickedAddress;
                      controller.pickedLocation = _pickedLocation;
                      controller.selectedImages = _selectedImages;
                      controller.existingPhotos = _initialPhotoUrls.map((url) => url.replaceFirst("${MyConfig.myurl}/", "")).toList();

                      final validationError = controller.validateFields();
                      if (validationError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError)));
                        return;
                      }

                      try {
                        final userId = await _getUserId();
                        if (userId == null) {
                          CustomSnackbar.show(context, AppText.somethingWrong(lang), Colors.white, Colors.redAccent);
                          return;
                        }

                        bool success = await controller.updateReport(widget.reportId, userId);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(AppText.updateReportSuccess(lang))));
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppText.failedToUpload(lang))));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
}
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
  String? _pickedAddress;
  GoogleMapController? _mapController;
  String? selectedType;
  LatLng? _pickedLocation;
  List<File> _selectedImages = [];

  final List<String> type = ['Pothole', 'Road Damage', 'Traffic Light'];
  final ImagePicker _picker = ImagePicker();

  Map<String, String> issueTypeMapping = {
    "Banjir": "Drainage",
    "Lain-lain": "Other",
    "Lubang Jalan": "Pothole",
    "Kemudahan Pengangkutan Awam": "Public Transport Facilities",
    "Tanda Jalan": "Road Sign",
    "Keselamatan tepi jalan": "Roadside Safety",
    "Lampu Jalan": "Street Light",
    "Lampu Isyarat": "Traffic Light",
  };
  
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    _mapController?.dispose(); 
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();

    _loadReportDetails(); // ✅ ONLY DATA SOURCE

    
  }

  Future<void> _pickFromCamera() async {
    if (_selectedImages.length >= 3) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    int remainingSlots = 3 - _selectedImages.length;
    if (remainingSlots <= 0) return;

    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
    );

    if (images.isNotEmpty) {
      setState(() {
        final List<XFile> selectedLimit = images.take(remainingSlots).toList();
        
        for (var image in selectedLimit) {
          _selectedImages.add(File(image.path));
        }
      });

      if (images.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Only $remainingSlots images were added (Max 3 allowed)")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final List<String> issueTypes = AppText.getList(lang.isEnglish);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    ),
                    Expanded(
                      child: Text("Edit Report",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Type Dropdown
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Type of Issue", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  isExpanded: true,
                  elevation: 4,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  iconSize: 28,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  items: issueTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => selectedType = v),
                  decoration: InputDecoration(
                    hintText: "Select Type",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Title", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter Title of Issue",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Description", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
                const SizedBox(height: 5),
                TextField(
                  maxLines: 4,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Describe the issue in detail",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Location Picker
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Location", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
                const SizedBox(height: 5),
                TextField(
                  readOnly: true,
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: "Select location from map",
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
                            if (result != null && result is Map) {
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

                // Small Map Preview (only visible if user picked location)
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
                        initialCameraPosition: CameraPosition(
                          target: _pickedLocation!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId("report_location"),
                            position: _pickedLocation!,
                          ),
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Photos", 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500
                    )
                  )
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    if (_selectedImages.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You can only upload up to 3 photos.")),
                      );
                    }
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
                              title: const Text("Take Photo"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickFromCamera();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text("Choose from Gallery"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickFromGallery();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                    ),
                    child: _selectedImages.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Add Photos (max 3)", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _initialPhotoUrls.length + _selectedImages.length < 3 
                            ? _initialPhotoUrls.length + _selectedImages.length + 1
                            : _initialPhotoUrls.length + _selectedImages.length,
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
                                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                ),
                                child: const Icon(Icons.add_a_photo, color: Colors.grey),
                              ),
                            );
                          }

                          // Show local file
                          if (index >= _initialPhotoUrls.length) {
                            int localIndex = index - _initialPhotoUrls.length;
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

                          // Show initial URL
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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Assign controller values to ReportController
                        final controller = ReportController();
                        controller.titleController.text = titleController.text.trim();
                        controller.descriptionController.text = descriptionController.text.trim();
                        controller.selectedType = selectedType;
                        controller.pickedAddress = _pickedAddress;
                        controller.pickedLocation = _pickedLocation;
                        controller.selectedImages = _selectedImages;
                        controller.existingPhotos = _initialPhotoUrls; // ✅ ADD THIS

                        final validationError = controller.validateFields();
                        if (validationError != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(validationError)),
                          );
                          return;
                        }

                        try {
                          // Pass the report id if updating
                          final userId = await _getUserId();
                          if (userId == null) {
                            CustomSnackbar.show(
                              context,
                              "Something went wrong. Please log in again.",
                              Colors.white,         // Text color
                              Colors.redAccent,   // Background color
                            );
                            return;
                          }

                          final int reportId = widget.reportId;

                          bool success = await controller.updateReport(reportId, userId);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Report updated successfully!")),
                            );
                            Navigator.pop(context, true);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed: $e")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.2); // splash effect
                            }
                            return null;
                          },
                        ),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
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


  void _showPickerOptions() {
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
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
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
    final dynamic id = prefs.get('user_id'); // get() returns dynamic
    
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> _loadReportDetails() async {
    final controller = ReportController();
    final data = await controller.getReportById(widget.reportId);

    final langProvider = context.read<LanguageProvider>();
    final bool isEnglish = langProvider.isEnglish;
    final List<String> currentIssueTypes = AppText.getList(isEnglish);

    // Helper function to safely match dropdown value ignoring case
    String? matchDropdown(List<String> list, String value) {
      try {
        return list.firstWhere(
          (e) => e.toLowerCase() == value.toLowerCase(),
        );
      } catch (e) {
        return null; // if no match, return null
      }
    }

    setState(() {
      // Load basic fields
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      locationController.text = data['location_text'] ?? '';
      _pickedAddress = data['location_text'];

      // Load issue type (handles lowercase from DB)
      String? apiIssueType = data['issue_type']?.trim();
      if (apiIssueType != null) {
        if (isEnglish) {
          selectedType = matchDropdown(currentIssueTypes, apiIssueType);
        } else {
          // Malay version: convert English DB value to Malay
          final englishToMalay = issueTypeMapping.map(
            (k, v) => MapEntry(v.toLowerCase(), k),
          );
          String? malayValue = englishToMalay[apiIssueType.toLowerCase()];
          if (malayValue != null) {
            selectedType = matchDropdown(currentIssueTypes, malayValue);
          }
        }
      }

      // Load location
      final lat = double.tryParse(data['latitude'].toString());
      final lng = double.tryParse(data['longitude'].toString());
      if (lat != null && lng != null) {
        _pickedLocation = LatLng(lat, lng);
        locationController.text = data['location_text'] ?? '';
      }

      // Load photos
      _initialPhotoUrls = List<String>.from(data['photos'] ?? []);
    });
  }


}

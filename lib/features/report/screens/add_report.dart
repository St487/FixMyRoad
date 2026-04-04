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

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  @override
  void dispose() {
    _mapController?.dispose(); 
    super.dispose();
  }

  GoogleMapController? _mapController;
  
  // final List<String> issueTypes = AppText.getList(lang.isEnglish);
  String? selectedType;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final report = context.read<ReportController>();
    if (report.selectedImages.length >= 3) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        report.selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final report = context.read<ReportController>();
    int remainingSlots = 3 - report.selectedImages.length;
    if (remainingSlots <= 0) return;

    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 70,
    );

    if (images.isNotEmpty) {
      setState(() {
        final List<XFile> selectedLimit = images.take(remainingSlots).toList();
        for (var image in selectedLimit) {
          report.selectedImages.add(File(image.path));
        }
      });

      if (images.length > remainingSlots) {

        CustomSnackbar.show(
          context,
          "Only $remainingSlots images were added (Max 3 allowed)",
          Colors.white,         // Text color
          Colors.black,   // Background color
        );
      }
    }
  }

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
  Widget build(BuildContext context) {
    final report = context.watch<ReportController>();
    final lang = context.watch<LanguageProvider>();
    final List<String> issueTypes = AppText.getList(lang.isEnglish);
    return WillPopScope(
        onWillPop: () async {
        report.clearForm();
        return true; // allow pop
      },
      child: Scaffold(
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
                        child: Text(AppText.addReport(lang.isEnglish),
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
                    child: Text(AppText.reportType(lang.isEnglish),
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
                    onChanged: (v) {
                      setState(() {
                        selectedType = v; 
                        if (lang.isEnglish) {
                          report.selectedType = v;
                        } else {
                          report.selectedType = issueTypeMapping[v!] ?? v;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppText.selectType(lang.isEnglish),
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
                    child: Text(AppText.title(lang.isEnglish),
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: report.titleController,
                    decoration: InputDecoration(
                      hintText: AppText.inputTitle(lang.isEnglish),
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
                    child: Text(AppText.description(lang.isEnglish),
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    maxLines: 4,
                    controller: report.descriptionController,
                    decoration: InputDecoration(
                      hintText: AppText.inputDescription(lang.isEnglish),
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
                    child: Text(AppText.location(lang.isEnglish),
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  TextField(
        readOnly: true,
        controller: TextEditingController(text: report.pickedAddress ?? ''),
        decoration: InputDecoration(
      hintText: AppText.selectLocation(lang.isEnglish),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: Colors.white,
      filled: true,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (report.pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  report.pickedLocation = null;
                  report.pickedAddress = null;
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
                  const SizedBox(height: 10),
      
                  // Small Map Preview (only visible if user picked location)
                  // Small Map Preview
                if (report.pickedLocation != null)
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
                          target: report.pickedLocation!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId("report_location"),
                            position: report.pickedLocation!,
                          ),
                        },
                      ),
                    ),
                  ),
      
                  const SizedBox(height: 20),
      
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10),
                    child: Text(AppText.addReport(lang.isEnglish), 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      )
                    )
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      if (report.selectedImages.length >= 3) {
                        CustomSnackbar.show(
                          context,
                          "Maximum of 3 images allowed.",
                          Colors.white,         // Text color
                          Colors.black,   // Background color
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
                      child: report.selectedImages.isEmpty
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
                          itemCount: report.selectedImages.length < 3 ? report.selectedImages.length + 1 : report.selectedImages.length,
                          itemBuilder: (context, index) {
                            if (index == report.selectedImages.length) {
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
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: FileImage(report.selectedImages[index]),
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
                                        report.selectedImages.removeAt(index);
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
                  const SizedBox(height: 40),
      
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                        final error = report.validateFields();
                        if (error != null) {
                          CustomSnackbar.show(
                            context,
                            error,
                            Colors.white,         // Text color
                            Colors.redAccent,   // Background color
                          );
                          return;
                        }
      
                        try {
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
      
                          bool success = await report.submitReport(userId);
                          if (success) {
                            CustomSnackbar.show(
                              context,
                              "Report submitted successfully!",
                              Colors.white,         // Text color
                              Colors.greenAccent,   // Background color
                            );
      
                            report.clearForm();
      
                            setState(() {
                              selectedType = null;
                            });
                          }
                        } catch (e) {
                          CustomSnackbar.show(
                              context,
                              e.toString(),
                              Colors.white,         // Text color
                              Colors.redAccent,   // Background color
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
                        child: Text(
                          AppText.submitReport(lang.isEnglish),
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
    return prefs.getInt('user_id'); // make sure you stored it as int
  }

}

import 'package:fix_my_road/screen/login_register/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddReport extends StatefulWidget {
  const AddReport({super.key});

  @override
  State<AddReport> createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    _mapController?.dispose(); 
    super.dispose();
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? _pickedAddress;
  GoogleMapController? _mapController;

  final List<String> type = ['Pothole', 'Road Damage', 'Traffic Light'];
  String? selectedType;
  final ImagePicker _picker = ImagePicker();

  LatLng? _pickedLocation;
  List<File> _selectedImages = [];

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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 110),
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
                      child: Text("Add Your Report Here",
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
                  items: type.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                  controller: TextEditingController(text: _pickedAddress ?? ''),
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
                        itemCount: _selectedImages.length < 3 ? _selectedImages.length + 1 : _selectedImages.length,
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
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
                                    image: FileImage(_selectedImages[index]),
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
                                      _selectedImages.removeAt(index);
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
                Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromARGB(255, 126, 105, 211),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(91, 79, 79, 79),
                          spreadRadius: 1,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _clearForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Report Submitted Successfully!")),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "Submit Report",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                )
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

  void _clearForm() {
    setState(() {
      titleController.clear();
      descriptionController.clear();

      selectedType = null;
      _pickedLocation = null;
      _pickedAddress = null;
      _selectedImages = [];
    });
  }


}

import 'dart:io';

import 'package:fix_my_road/features/auth/service/location_service.dart';
import 'package:fix_my_road/features/profile/controllers/get_profile.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final Color primaryPurple = Colors.deepPurple;
  
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> cities = [];
  String? selectedStateIso;
  String? selectedCity;
  bool isLoadingStates = true;
  bool isLoadingCities = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final postalController = TextEditingController();

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _loadStates();          
    await _loadProfileDefaults(); 
  });
  final auth = context.read<ProfileController>();

    if (!mounted) return;

    firstNameController.text = auth.firstName;
    lastNameController.text = auth.lastName;
    phoneController.text = auth.phone ?? "";
    addressController.text = auth.address ?? "";
    postalController.text = auth.postalCode ?? "";
}

Future<List<Map<String, dynamic>>> _loadStates() async {
  final data = await LocationService.fetchStates();
  if (!mounted) return data;
  setState(() {
    states = data;
    isLoadingStates = false;
  });
  return data;
}

Future<void> _loadProfileDefaults() async {
  final auth = context.read<ProfileController>();
  await auth.getProfile();

  if (!mounted) return;

  if (auth.state != null && auth.state!.isNotEmpty) {

    final stateObj = states.firstWhere(
      (e) => e['name'].toString().toLowerCase() ==
             auth.state!.toLowerCase(),
      orElse: () => {},
    );

    final iso = stateObj.isNotEmpty ? stateObj['iso2'] : null;

    if (iso != null) {
      setState(() {
        isLoadingCities = true;
      });

      final cityData = await LocationService.fetchCities(iso);

      if (!mounted) return;

      setState(() {
        cities = cityData;

        final cityExists = cityData.any(
          (c) => c['name'].toString().toLowerCase() ==
                 auth.city.toString().toLowerCase(),
        );

        selectedCity = cityExists ? auth.city : null;
        isLoadingCities = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<ProfileController>();
    const kBackground = Color.fromARGB(255, 247, 235, 255);
    const kGradientStart = Color.fromARGB(255, 251, 195, 226);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppText.editProfile(lang.isEnglish), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kGradientStart,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGradientStart, kBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: auth.profilePicture != null
                            ? NetworkImage("${MyConfig.myurl}/${auth.profilePicture}")
                            : const AssetImage("assets/images/personIcon.jpg") as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryPurple,
                      radius: 18,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {
                          _showImageSourceDialog();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(auth.email, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            Divider(color: Colors.grey[300], thickness: 1),
            // Form Fields
            _buildTextField(AppText.firstName(lang.isEnglish), firstNameController),
            _buildTextField(AppText.lastName(lang.isEnglish), lastNameController),
            _buildTextField(AppText.phoneNumber(lang.isEnglish), phoneController),
            _buildTextField(AppText.address(lang.isEnglish), addressController),
            _buildTextField(AppText.postalCode(lang.isEnglish), postalController),

            // State Dropdown
            _buildLabel(AppText.state(lang.isEnglish)),
            DropdownButtonFormField<String>(
              value: states.any((s) =>
                  s['name'].toString().toLowerCase() ==
                  auth.state.toString().toLowerCase())
              ? states.firstWhere((s) =>
                      s['name'].toString().toLowerCase() ==
                      auth.state.toString().toLowerCase())['name']
              : null,
              decoration: _inputDecoration(),
              hint: Text(isLoadingStates ? "Loading States..." : "Select State"),
              items: states.map((state) {
                return DropdownMenuItem(
                  value: state['name'].toString(),
                  child: Text(state['name']),
                );
              }).toList(),
              onChanged: (stateName) async {
                if (stateName == null) return;

                if (!mounted) return;

                setState(() {
                  auth.state = stateName;
                  selectedCity = null;
                });

                final selectedState = states.firstWhere(
                  (s) => s["name"] == stateName,
                  orElse: () => {},
                );

                final iso = selectedState.isNotEmpty ? selectedState["iso2"] : null;

                if (iso != null) {
                  final cityData = await LocationService.fetchCities(iso);
                  if (!mounted) return;
                  setState(() {
                    cities = cityData;
                  });
                }
              },
            ),
            SizedBox(height: 5),

            // City Dropdown
            _buildLabel(AppText.city(lang.isEnglish)),
            DropdownButtonFormField<String>(
              value: cities.any((c) => c['name'] == selectedCity)
                        ? selectedCity
                        : null,
              decoration: _inputDecoration(),
              hint: Text(isLoadingCities ? "Loading Cities..." : "Select City"),
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city['name'].toString(),
                  child: Text(city['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedCity = val),
            ),

            SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final auth = context.read<ProfileController>();

                  final result = await auth.updateProfile(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: auth.email,
                    phone: phoneController.text,
                    address: addressController.text,
                    postalCode: postalController.text,
                    state: (auth.state == null || auth.state!.isEmpty)
                        ? null
                        : auth.state,

                    city: (selectedCity == null || selectedCity!.isEmpty)
                        ? null
                        : selectedCity,
                  );

                  if (result['status'] == 'success') {
                    CustomSnackbar.show(
                      context,
                      result['message'],
                      Colors.white,
                      Colors.greenAccent,
                    );
                  } else {
                    CustomSnackbar.show(
                      context,
                      result['message'],
                      Colors.white,
                      Colors.redAccent,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
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
                child: Text(AppText.save(lang.isEnglish), style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(bottom: 8, top: 15),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel(label),
      TextField(
        controller: controller,
        enabled: enabled,
        decoration: _inputDecoration(isEnabled: enabled),
      ),
    ],
  );
}

  InputDecoration _inputDecoration({String? hint, bool isEnabled = true}) {
    return InputDecoration(
      hintText: hint,
      filled: !isEnabled,
      fillColor: isEnabled ? Colors.transparent : Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[400]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[400]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPurple, width: 2)),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // square
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF7864C8),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // ensures square crop
          cropStyle: CropStyle.circle, // optional: preview circle, still saves as square
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

      if (croppedFile != null) {
        
        File file = File(croppedFile.path);

        if (!mounted) return;

        final controller = context.read<ProfileController>();
        final result = await controller.uploadProfileImage(file);

        if (result['status'] == 'success') {
          await controller.getProfile(); 
          if (!mounted) return;
          CustomSnackbar.show(context, result['message'],Colors.white, Colors.greenAccent);
        } else {
          if (!mounted) return;
          CustomSnackbar.show(context, result['message'] ?? "Upload failed", Colors.white, Colors.red);
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Choose Image Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
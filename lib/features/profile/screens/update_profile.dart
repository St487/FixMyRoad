// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:fix_my_road/features/auth/service/location_service.dart';
import 'package:fix_my_road/features/profile/controllers/profileController.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:fix_my_road/utils/cameraPermission.dart';
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
  final Color secondaryPurple = const Color(0xFF9575CD);
  final Color kBackground = const Color(0xFFF8F9FE);

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final auth = context.read<ProfileController>();

    firstNameController.text = auth.firstName;
    lastNameController.text = auth.lastName;
    phoneController.text = auth.phone ?? "";
    addressController.text = auth.address ?? "";
    postalController.text = auth.postalCode ?? "";

    await _loadStates();
    await _loadProfileDefaults();
  });
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
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;
    final auth = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppText.editProfile(lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPurple,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, secondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondaryPurple, kBackground],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                _buildProfileImage(auth, lang),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    auth.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(AppText.firstName(lang), firstNameController, Icons.person_outline),
                        _buildTextField(AppText.lastName(lang), lastNameController, Icons.person_outline),
                        _buildTextField(AppText.phoneNumber(lang), phoneController, Icons.phone_android_outlined),
                        _buildTextField(AppText.address(lang), addressController, Icons.location_on_outlined),
                        _buildTextField(AppText.postalCode(lang), postalController, Icons.markunread_mailbox_outlined),
                        
                        const SizedBox(height: 10),
                        _buildDropdownSection(lang, auth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildSaveButton(auth, lang),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(ProfileController auth, bool lang) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: auth.profilePicture != null
                ? NetworkImage("${MyConfig.myurl}/${auth.profilePicture}")
                : const AssetImage("assets/images/personIcon.jpg") as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _showImageSourceDialog(lang),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryPurple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: _inputDecoration(icon: icon),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection(bool lang, ProfileController auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.state(lang), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: states.any((s) => s['name'].toString().toLowerCase() == auth.state.toString().toLowerCase())
              ? states.firstWhere((s) => s['name'].toString().toLowerCase() == auth.state.toString().toLowerCase())['name']
              : null,
          decoration: _inputDecoration(icon: Icons.map_outlined),
          hint: Text(isLoadingStates ? "Loading..." : AppText.inputState(lang)),
          items: states.map((state) => DropdownMenuItem(value: state['name'].toString(), child: Text(state['name']))).toList(),
          onChanged: (stateName) async {
            if (stateName == null) return;
            setState(() { auth.state = stateName; selectedCity = null; });
            final selectedState = states.firstWhere((s) => s["name"] == stateName, orElse: () => {});
            final iso = selectedState.isNotEmpty ? selectedState["iso2"] : null;
            if (iso != null) {
              final cityData = await LocationService.fetchCities(iso);
              if (!mounted) return;
              setState(() => cities = cityData);
            }
          },
        ),
        const SizedBox(height: 20),
        Text(AppText.city(lang), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: cities.any((c) => c['name'] == selectedCity) ? selectedCity : null,
          decoration: _inputDecoration(icon: Icons.location_city_outlined),
          hint: Text(isLoadingCities ? "Loading..." : AppText.inputCity(lang)),
          items: cities.map((city) => DropdownMenuItem(value: city['name'].toString(), child: Text(city['name']))).toList(),
          onChanged: (val) => setState(() => selectedCity = val),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ProfileController auth, bool lang) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [primaryPurple, secondaryPurple]),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
              Colors.greenAccent,
              Colors.white,
            );
          } else {
            CustomSnackbar.show(
              context,
              result['message'],
              Colors.redAccent,
              Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
        child: Text(AppText.save(lang), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: secondaryPurple),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryPurple, width: 1.5),
      ),
    );
  }

  Future<void> pickImage(ImageSource source, bool lang) async {
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
          CustomSnackbar.show(context, result['message'],Colors.greenAccent, Colors.white);
        } else {
          if (!mounted) return;
          CustomSnackbar.show(context, result['message'] ?? AppText.uploadFailed(lang), Colors.red, Colors.white);
        }
      }
    }
  }

  void _pickImageWithPermission(ImageSource source, bool lang) async {
    bool granted = await CameraPermissionHandler.checkAndRequest(context);
    if (!granted) return; // stop if permission denied

    await pickImage(source, lang);
  }

  void _showImageSourceDialog(bool lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar for better UX
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppText.chooseImageSource(lang),
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: AppText.takePhoto(lang),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageWithPermission(ImageSource.camera, lang);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: AppText.chooseGallery(lang),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageWithPermission(ImageSource.gallery, lang);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create the circular icon buttons seen in modern apps
  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
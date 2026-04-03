import 'package:fix_my_road/features/auth/service/location_service.dart';
import 'package:fix_my_road/features/profile/controllers/get_profile.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
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
    await _loadStates();          // MUST load first
    await _loadProfileDefaults(); // THEN map state
  });
}

Future<List<Map<String, dynamic>>> _loadStates() async {
  final data = await LocationService.fetchStates();
  setState(() {
    states = data;
    isLoadingStates = false;
  });
  return data;
}

Future<void> _loadProfileDefaults() async {
  final auth = context.read<ProfileController>();
  await auth.getProfile();

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

  void _loadCities(String stateIso) async {
  setState(() {
    isLoadingCities = true;
    cities = [];
    selectedCity = null;
  });

  final data = await LocationService.fetchCities(stateIso);

  setState(() {
    cities = data;
    isLoadingCities = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<ProfileController>();
    firstNameController.text = auth.firstName;
    lastNameController.text = auth.lastName;
    phoneController.text = auth.phone ?? "";
    addressController.text = auth.address ?? "";
    postalController.text = auth.postalCode ?? "";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: auth.profilePicture != null
                          ? NetworkImage("${MyConfig.myurl}/${auth.profilePicture}")
                          : const AssetImage("assets/images/personIcon.jpg") as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryPurple,
                      radius: 18,
                      child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Form Fields
            _buildTextField("First Name", firstNameController),
_buildTextField("Last Name", lastNameController),
_buildTextField("Phone No", phoneController),
_buildTextField("Address", addressController),
_buildTextField("Postal Code", postalController),

            // State Dropdown
            _buildLabel("State"),
            DropdownButtonFormField<String>(
              value: auth.state,
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

                setState(() {
                  auth.state = stateName; // store NAME
                  selectedCity = null;
                });

                final selectedState = states.firstWhere(
                  (s) => s["name"] == stateName,
                  orElse: () => {},
                );

                final iso = selectedState.isNotEmpty ? selectedState["iso2"] : null;

                if (iso != null) {
                  final cityData = await LocationService.fetchCities(iso);
                  setState(() {
                    cities = cityData;
                  });
                }
              },
            ),
            SizedBox(height: 15),

            // City Dropdown
            _buildLabel("City"),
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
                    state: selectedStateIso, // ⚠️ if DB expects ID, you must convert ISO → ID
                    city: selectedCity,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Save and Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
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
}
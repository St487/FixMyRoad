import 'package:fix_my_road/features/auth/controllers/auth_controller.dart';
import 'package:fix_my_road/features/auth/service/location_service.dart';
import 'package:fix_my_road/shared/animation/animated_button.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/features/auth/screens/login_screen.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  @override
  void initState() {
    super.initState();
    loadStates();
  }

  void loadStates() async {
    final states = await LocationService.fetchStates();
    setState(() {
      stateList = states;
    });
  }

  List<Map<String, dynamic>> stateList = [];
  List<Map<String, dynamic>> cityList = [];
  String? selectedCity;
  String? selectedState;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 248, 187, 222),
              Color.fromARGB(255, 252, 217, 192),
              Color.fromARGB(255, 204, 192, 249),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 20.0),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.85,
                  width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppText.completeProfile(lang.isEnglish),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),

                          // First Name Field
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.firstName(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            controller: auth.firstName,
                            decoration: InputDecoration(
                              hintText: AppText.inputFirstName(lang.isEnglish),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Last Name Field
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.lastName(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            controller: auth.lastName,
                            decoration: InputDecoration(
                              hintText: AppText.inputLastName(lang.isEnglish),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Address Field
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.address(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            controller: auth.address,
                            keyboardType: TextInputType.multiline,
                            minLines: 3, 
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: AppText.inputAddress(lang.isEnglish),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Postal Code Field
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.postalCode(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            controller: auth.postalCode,
                            decoration: InputDecoration(
                              hintText: AppText.inputPostalCode(lang.isEnglish),
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),

                          // State Dropdown
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.state(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: auth.state,
                            hint: const Text("Select State"),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            items: stateList.map<DropdownMenuItem<String>>((s) {
                              return DropdownMenuItem<String>(
                                value: s["name"].toString(),
                                child: Text(s["name"].toString()),
                              );
                            }).toList(),
                            onChanged: (String? stateName) async {
                              if (stateName == null) return;

                              // ✅ store NAME
                              auth.updateState(stateName);

                              // 🔥 find ISO for API
                              final selectedState = stateList.firstWhere(
                                (s) => s["name"] == stateName,
                                orElse: () => {},
                              );

                              final iso = selectedState.isNotEmpty ? selectedState["iso2"] : null;

                              if (iso != null) {
                                final cities = await LocationService.fetchCities(iso);
                                setState(() {
                                  cityList = cities;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),

                          // City Dropdown
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              AppText.city(lang.isEnglish),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: auth.city,
                            hint: const Text("Select City"),
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            items: cityList.map<DropdownMenuItem<String>>((c) {
                              return DropdownMenuItem<String>(
                                value: c["name"].toString(),
                                child: Text(c["name"].toString()),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              auth.updateCity(value);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Done Button
                          AnimatedButton(
                            width: 250,
                            onPressed: () async {
                              final result = await context.read<AuthController>().completeProfile();
                              if (!mounted) return;
                              if (result['status'] == 'success') {
                                CustomSnackbar.show(context, result['message'],Colors.white, Colors.greenAccent);
                                Navigator.of(context).pushAndRemoveUntil(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const LoginScreen(),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                  (route) => false, // removes all existing routes
                                );
                                auth.clearAll();
                              } else {
                                CustomSnackbar.show(context, result['message'] ?? "Error occurred",Colors.redAccent, Colors.white);
                              }
                            },
                            
                            child: Text(
                              AppText.doneButton(lang.isEnglish),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    )
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}
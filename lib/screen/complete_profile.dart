import 'package:fix_my_road/animation/animated_button.dart';
import 'package:fix_my_road/screen/login_screen.dart';
import 'package:flutter/material.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final List<String> cities = ['Kuala Lumpur', 'George Town', 'Johor Bahru'];
  final List<String> states = ['Selangor', 'Penang', 'Johor'];
  String? selectedCity;
  String? selectedState;

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
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
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'First Name',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Your First Name",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'Last Name',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Your Last Name",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'Address',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 3, 
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: "Your Address",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'Postal Code',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Your Postal Code",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'State',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedState,
                            isExpanded: true,
                            elevation: 4,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            items: states
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedState = v),
                            decoration: InputDecoration(
                              hintText: "Select State",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: const Text(
                              'City',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedCity,
                            isExpanded: true,
                            elevation: 4,
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            iconSize: 28,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                            items: cities
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedCity = v),
                            decoration: InputDecoration(
                              hintText: "Select City",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                          SizedBox(height: 30),
                          AnimatedButton(
                            width: 250,
                            // onPressed: () {
                            //   TransitionButton.replaceWithFade(context, const LoginScreen());
                            // },
                            onPressed: () {
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
                            },
                            child: const Text(
                              "Done",
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
import 'package:fix_my_road/screen/login_register/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                          return const LoginScreen();
                        }));}, child: Text("Logout")),
      ),
    );
  }
}
import 'package:fix_my_road/screen/login_register/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEnglish = true;
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 247, 235, 255),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 80),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 126, 105, 211),
            ),
            child: Column(
              children: [
                const Text(
                  "My Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
                ),
                const SizedBox(height: 25),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage("assets/images/personIcon.jpg"),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF7864C8), size: 18),
                          onPressed: () {
                            print("Edit Profile Pressed");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'User',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'userEmail@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -50),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfileOption(
                    icon: Icons.person_sharp,
                    title: "Update Profile",
                    onTap: () {
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.lock_outline_rounded,
                    title: "Change Password",
                    onTap: () {
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.language_rounded,
                    title: "Choose Language",
                    subtitle: isEnglish ? "English" : "Malay",
                    onTap: () => _showLanguageDialog(),
                  ),
                  _buildProfileOption(
                    icon: Icons.logout_rounded,
                    title: "Log Out",
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 50),
        ],
      ),
    ),
  );
}
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = const Color.fromARGB(255, 235, 155, 201),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text("English"),
            leading: const Icon(Icons.abc),
            onTap: () {
              setState(() => isEnglish = true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Malay"),
            leading: const Icon(Icons.language),
            onTap: () {
              setState(() => isEnglish = false);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  
  
}
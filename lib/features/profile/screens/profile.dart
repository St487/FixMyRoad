import 'dart:io';

import 'package:fix_my_road/features/auth/screens/login_screen.dart';
import 'package:fix_my_road/features/profile/controllers/profileController.dart';
import 'package:fix_my_road/features/profile/screens/change_password_step1.dart';
import 'package:fix_my_road/features/profile/screens/contact.dart';
import 'package:fix_my_road/features/profile/screens/update_profile.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/confirm_dialog.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:fix_my_road/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileController>().getProfile();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ProfileController>();
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
      body: auth.isProfileLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                  Text(
                    AppText.myProfile(lang),
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
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: (auth.profilePicture != null &&
                              auth.profilePicture!.isNotEmpty &&
                              auth.profilePicture != "null")
                          ? NetworkImage("${MyConfig.myurl}/${auth.profilePicture}")
                          : const AssetImage("assets/images/personIcon.jpg"),
                        ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: CircleAvatar(
                      //     backgroundColor: Colors.white,
                      //     radius: 18,
                      //     child: IconButton(
                      //       icon: const Icon(Icons.edit, color: Color(0xFF7864C8), size: 18),
                      //       onPressed: () {
                      //         _showImageSourceDialog();
                      //       },
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    auth.firstName.isEmpty ? AppText.user(lang) : auth.firstName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    auth.email.isEmpty ? "Email" : auth.email,
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
                      title: AppText.editProfile(lang),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                ChangeNotifierProvider.value(
                              value: context.read<ProfileController>(),
                              child: UpdateProfileScreen(),
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.lock_outline_rounded,
                      title: AppText.changePassword(lang),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                ChangeNotifierProvider.value(
                              value: context.read<ProfileController>(),
                              child: ChangePasswordStep1(),
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.language_rounded,
                      title: AppText.chooseLanguage(lang),
                      subtitle: lang ? "English" : "Malay",
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showLanguageDialog();
                      },
                    ),  
                    _buildProfileOption(
                      icon: Icons.call,
                      title: AppText.contact(lang),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ContactScreen()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.logout_rounded,
                      title: AppText.logout(lang),
                      onTap: () async { 
                        HapticFeedback.lightImpact();
                        final confirm = await ConfirmDialog.show(
                        context: context,
                        title: AppText.logout(lang),
                        message: AppText.confirmLogout(lang),
                        cancelText: AppText.cancel(lang),
                        confirmText: AppText.logout(lang),
                      );

                      if (confirm != true) return;

                      await _handleLogout(context); },
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
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
          ),
          ListTile(
            title: const Text("English"),
            leading: const Icon(Icons.abc),
            onTap: () {
              HapticFeedback.selectionClick();
              lang.setLanguage(true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Malay"),
            leading: const Icon(Icons.language),
            onTap: () {
              HapticFeedback.selectionClick();
              lang.setLanguage(false);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // final prefs = await SharedPreferences.getInstance();

    // await prefs.clear();
    NotificationService().stop();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Future<void> pickImage(ImageSource source) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: source);

  //   if (pickedFile != null) {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: pickedFile.path,
  //     aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // square
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: const Color(0xFF7864C8),
  //         toolbarWidgetColor: Colors.white,
  //         initAspectRatio: CropAspectRatioPreset.square,
  //         lockAspectRatio: true, // ensures square crop
  //         cropStyle: CropStyle.circle, // optional: preview circle, still saves as square
  //       ),
  //       IOSUiSettings(
  //         title: 'Crop Image',
  //         aspectRatioLockEnabled: true,
  //         resetAspectRatioEnabled: false,
  //       ),
  //     ],
  //   );

  //     if (croppedFile != null) {
        
  //       File file = File(croppedFile.path);

  //       if (!mounted) return;

  //       final controller = context.read<ProfileController>();
  //       final result = await controller.uploadProfileImage(file);

  //       if (result['status'] == 'success') {
  //         await controller.getProfile(); 
  //         if (!mounted) return;
  //         CustomSnackbar.show(context, result['message'],Colors.white, Colors.greenAccent);
  //       } else {
  //         if (!mounted) return;
  //         CustomSnackbar.show(context, result['message'] ?? "Upload failed", Colors.white, Colors.red);
  //       }
  //     }
  //   }
  // }

  // void _showImageSourceDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
  //     builder: (context) => Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         const Padding(
  //           padding: EdgeInsets.all(20),
  //           child: Text(
  //             "Choose Image Source",
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.photo_library),
  //           title: const Text("Gallery"),
  //           onTap: () {
  //             Navigator.pop(context);
  //             pickImage(ImageSource.gallery);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.camera_alt),
  //           title: const Text("Camera"),
  //           onTap: () {
  //             Navigator.pop(context);
  //             pickImage(ImageSource.camera);
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //       ],
  //     ),
  //   );
  // }
  
  
}
import 'package:fix_my_road/features/auth/screens/splashscreen.dart';
import 'package:fix_my_road/features/home/controllers/detailController.dart';
import 'package:fix_my_road/features/home/controllers/homeController.dart';
import 'package:fix_my_road/features/password/controllers/passwordController.dart';
import 'package:fix_my_road/features/profile/controllers/changePasswordController.dart';
import 'package:fix_my_road/features/profile/controllers/profileController.dart';
import 'package:fix_my_road/features/report/controllers/reportController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/language_provider.dart';
import 'features/auth/controllers/authController.dart';

void main() {
  runApp(
   MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthController()), 
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => DetailController(issueId: 0)),
        ChangeNotifierProvider(create: (_) => Changepasswordcontroller()),
        ChangeNotifierProvider(create: (_) => PasswordController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splashscreen(),
    );
  }
}

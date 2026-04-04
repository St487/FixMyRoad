import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  final String phoneNumber = "+60123456789"; // Replace with official number
  final String emailAddress = "support@fixmyroad.com"; // Replace with official email
  final Color primaryColor = Colors.deepPurple;

  const ContactScreen({super.key});

  // Launch phone dialer
  void _launchPhone(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch $phone");
    }
  }

  // Launch email client
  void _launchEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Inquiry&body=Hello,',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("Could not launch $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.contactUs(lang.isEnglish)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Phone Section
            Text(
              AppText.phoneNumber(lang.isEnglish),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchPhone(phoneNumber),
              child: Row(
                children: [
                  Icon(Icons.phone, color: primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    phoneNumber,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Email Section
            Text(
              AppText.email(lang.isEnglish),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchEmail(emailAddress),
              child: Row(
                children: [
                  Icon(Icons.email, color: primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    emailAddress,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
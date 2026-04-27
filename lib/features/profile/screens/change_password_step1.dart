import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/primary_button.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fix_my_road/features/profile/controllers/changePasswordController.dart';
import 'change_password_step2.dart';

class ChangePasswordStep1 extends StatefulWidget {
  const ChangePasswordStep1({super.key});

  @override
  State<ChangePasswordStep1> createState() => _ChangePasswordStep1State();
}

class _ChangePasswordStep1State extends State<ChangePasswordStep1> {
  final Color primaryPurple = Colors.deepPurple;
  final Color secondaryPurple = const Color(0xFF9575CD);
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  final color = Color.fromARGB(255, 126, 105, 211);
  @override
  Widget build(BuildContext context) {
    
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;
    final auth = context.watch<Changepasswordcontroller>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(AppText.changePassword(lang), style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            Row(
              children: [
                _buildStepIndicator(true, AppText.verify(lang), lang),
                _buildDivider(),
                _buildStepIndicator(false, AppText.newPassword(lang), lang),
              ],
            ),
            const SizedBox(height: 40),
            
            Text(
              AppText.verifyIdentity(lang),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.enterCurrentPassword(lang),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: AppText.currentPassword(lang),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isObscured = !_isObscured);
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Action Button
            PrimaryButton(
              text: AppText.continueButton(lang),
              isLoading: auth.isLoading,
              onPressed: () {
                HapticFeedback.lightImpact();
                _handleVerify(lang);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerify(lang) async {
    final auth = context.read<Changepasswordcontroller>();
    final res = await auth.verifyCurrentPassword(_passwordController.text);

    if (!mounted) return;

    if (res['status'] == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordStep2()),
      );
    } else {
      CustomSnackbar.show(context, res['message'] ?? AppText.somethingWrong(lang), Colors.redAccent, Colors.white);
    }
  }

  Widget _buildStepIndicator(bool active, String label, lang) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active ? color : Colors.grey[300],
          child: Text(label == AppText.verify(lang) ? "1" : "2", style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: active ? color : Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Expanded(
      child: Container(height: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20)),
    );
  }
}
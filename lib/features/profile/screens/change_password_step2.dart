import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/primary_button.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fix_my_road/features/profile/controllers/changePasswordController.dart';

class ChangePasswordStep2 extends StatefulWidget {
  const ChangePasswordStep2({super.key});

  @override
  State<ChangePasswordStep2> createState() => _ChangePasswordStep2State();
}

class _ChangePasswordStep2State extends State<ChangePasswordStep2> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final Color primaryPurple = Colors.deepPurple;
  final Color secondaryPurple = const Color(0xFF9575CD);
  final color = Color.fromARGB(255, 126, 105, 211);
  bool _obscure1 = true;
  bool _obscure2 = true;

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
        title: Text(AppText.newPassword(lang), style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                _buildStepIndicator(true, AppText.verify(lang), lang),
                _buildDivider(),
                _buildStepIndicator(true, AppText.newPassword(lang), lang),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              AppText.createNewPassword(lang),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.newPasswordInstructions(lang),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 32),

            // New Password Field
            _buildPasswordField(
              controller: _newPassController,
              label: AppText.newPassword(lang),
              helperText: AppText.passwordHint(lang),
              isObscured: _obscure1,
              onToggle: () => setState(() => _obscure1 = !_obscure1),
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPassController,
              helperText: "",
              label: AppText.confirmPassword(lang),
              isObscured: _obscure2,
              onToggle: () => setState(() => _obscure2 = !_obscure2),
            ),
            const SizedBox(height: 20),

            // Update Button
            PrimaryButton(
              text: AppText.updatePassword(lang),
              isLoading: auth.isLoading,
              onPressed: () => _handleUpdate(lang),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String helperText,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_reset_rounded),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        helperText: helperText,
      ),
    );
  }

  Future<void> _handleUpdate(lang) async {
    if (_newPassController.text != _confirmPassController.text) {
      CustomSnackbar.show(context, AppText.passwordsDoNotMatch(lang), Colors.redAccent, Colors.white);
      return;
    }

    if (_newPassController.text.length < 6) {
      CustomSnackbar.show(context, AppText.passwordTooShort(lang), Colors.redAccent, Colors.white);
      return;
    }

    final auth = context.read<Changepasswordcontroller>();
    final res = await auth.updatePassword(_newPassController.text);

    if (!mounted) return;

    if (res['status'] == "success") {
      CustomSnackbar.show(context, res['message'] ?? AppText.passwordChangeSuccess(lang), Colors.green, Colors.white);
      // Go back to profile or home
      Navigator.popUntil(context, (route) => route.isFirst);
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
      child: Container(height: 1, color: color, margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20)),
    );
  }
}
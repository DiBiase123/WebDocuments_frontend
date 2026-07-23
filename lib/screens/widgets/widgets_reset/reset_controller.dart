import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetController extends ChangeNotifier {
  final _service = WebDocumentsService();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isSuccess = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> reset(String token) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.resetPassword(
        token,
        passwordController.text,
        confirmPasswordController.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_password', passwordController.text);
      await prefs.setBool('reset_done', true);
      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

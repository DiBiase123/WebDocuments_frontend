import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_storage.dart';

class LoginController extends ChangeNotifier {
  final _service = WebDocumentsService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false;
  String? errorMessage;

  Future<void> loadCredentials() async {
    final creds = await LoginStorage.loadCredentials();
    emailController.text = creds['email'] ?? '';
    passwordController.text = creds['password'] ?? '';
    rememberMe = creds['rememberMe'] ?? false;
    notifyListeners();
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? v) {
    rememberMe = v ?? false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.login(
        emailController.text.trim(),
        passwordController.text,
      );
      await LoginStorage.saveCredentials(
        emailController.text.trim(),
        passwordController.text,
        rememberMe,
      );
      final roleData = await _service.getMyRole();
      final userRole = roleData['role'] ?? 'USER';
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => userRole == 'ADMIN' || userRole == 'SUPER_ADMIN'
              ? const WebDocumentsDashboard()
              : const WebDocumentsList(),
        ),
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

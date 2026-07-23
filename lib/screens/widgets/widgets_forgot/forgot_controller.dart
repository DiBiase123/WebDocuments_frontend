import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class ForgotController extends ChangeNotifier {
  final _service = WebDocumentsService();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _service.forgotPassword(emailController.text.trim());
      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

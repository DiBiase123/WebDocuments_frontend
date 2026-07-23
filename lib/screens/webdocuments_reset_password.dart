import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_auth_form_wrapper.dart';
import 'package:webdocuments/screens/widgets/widgets_reset/reset_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_reset/reset_validators.dart';
import 'package:webdocuments/screens/widgets/widgets_reset/reset_form_fields.dart';

class WebDocumentsResetPassword extends StatefulWidget {
  final String token;
  const WebDocumentsResetPassword({super.key, required this.token});
  @override
  State<WebDocumentsResetPassword> createState() =>
      _WebDocumentsResetPasswordState();
}

class _WebDocumentsResetPasswordState extends State<WebDocumentsResetPassword> {
  final _ctrl = ResetController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl.isSuccess) {
      final navigator = Navigator.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
            );
          }
        });
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Reimposta Password')),
      body: AuthFormWrapper(
        child: _ctrl.isSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text('Password reimpostata!'),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              )
            : Form(
                key: _ctrl.formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_open,
                      size: 80,
                      color: Color(0xFFF08A5D),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nuova Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ResetFormFields(
                      passwordController: _ctrl.passwordController,
                      confirmPasswordController:
                          _ctrl.confirmPasswordController,
                      obscurePassword: _ctrl.obscurePassword,
                      obscureConfirmPassword: _ctrl.obscureConfirmPassword,
                      onTogglePassword: _ctrl.togglePassword,
                      onToggleConfirmPassword: _ctrl.toggleConfirmPassword,
                      passwordValidator: ResetValidators.validatePassword,
                      confirmPasswordValidator: (v) =>
                          ResetValidators.validateConfirmPassword(
                            v,
                            _ctrl.passwordController.text,
                          ),
                      onFieldSubmitted: (_) => _ctrl.reset(widget.token),
                    ),
                    const SizedBox(height: 24),
                    if (_ctrl.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _ctrl.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _ctrl.isLoading
                            ? null
                            : () => _ctrl.reset(widget.token),
                        child: _ctrl.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('REIMPOSTA PASSWORD'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

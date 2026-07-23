import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_auth_form_wrapper.dart';
import 'package:webdocuments/screens/widgets/widgets_register/register_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_register/register_validators.dart';
import 'package:webdocuments/screens/widgets/widgets_register/register_form_fields.dart';
import 'package:webdocuments/screens/widgets/widgets_register/register_success_dialog.dart';

class WebDocumentsRegister extends StatefulWidget {
  const WebDocumentsRegister({super.key});
  @override
  State<WebDocumentsRegister> createState() => _WebDocumentsRegisterState();
}

class _WebDocumentsRegisterState extends State<WebDocumentsRegister> {
  final _ctrl = RegisterController();

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

  Future<void> _register() async {
    final ok = await _ctrl.register();
    if (ok && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            RegisterSuccessDialog(email: _ctrl.emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AuthFormWrapper(
        child: Form(
          key: _ctrl.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add,
                size: 80,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text('WebDocuments', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Crea il tuo account', style: theme.textTheme.bodySmall),
              const SizedBox(height: 40),
              RegisterFormFields(
                emailController: _ctrl.emailController,
                usernameController: _ctrl.usernameController,
                passwordController: _ctrl.passwordController,
                confirmPasswordController: _ctrl.confirmPasswordController,
                obscurePassword: _ctrl.obscurePassword,
                obscureConfirmPassword: _ctrl.obscureConfirmPassword,
                onTogglePassword: _ctrl.togglePassword,
                onToggleConfirmPassword: _ctrl.toggleConfirmPassword,
                emailValidator: RegisterValidators.validateEmail,
                usernameValidator: RegisterValidators.validateUsername,
                passwordValidator: RegisterValidators.validatePassword,
                confirmPasswordValidator: (v) =>
                    RegisterValidators.validateConfirmPassword(
                      v,
                      _ctrl.passwordController.text,
                    ),
                onFieldSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 24),
              if (_ctrl.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _ctrl.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _ctrl.isLoading ? null : _register,
                  child: _ctrl.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('REGISTRATI'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hai già un account? ',
                    style: theme.textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsLogin(),
                      ),
                    ),
                    child: Text(
                      'Accedi',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_register.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_auth_form_wrapper.dart';
import 'package:webdocuments/screens/widgets/widgets_forgot/forgot_password_dialog.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_validators.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_form_fields.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_actions.dart';
import 'package:webdocuments/screens/widgets/widgets_login/login_remember_me.dart';

class WebDocumentsLogin extends StatefulWidget {
  const WebDocumentsLogin({super.key});
  @override
  State<WebDocumentsLogin> createState() => _WebDocumentsLoginState();
}

class _WebDocumentsLoginState extends State<WebDocumentsLogin> {
  final _ctrl = LoginController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.loadCredentials();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                Icons.lock_outline,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('WebDocuments', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Area riservata', style: theme.textTheme.bodySmall),
              const SizedBox(height: 40),
              LoginFormFields(
                emailController: _ctrl.emailController,
                passwordController: _ctrl.passwordController,
                obscurePassword: _ctrl.obscurePassword,
                onTogglePassword: _ctrl.togglePassword,
                emailValidator: LoginValidators.validateEmail,
                passwordValidator: LoginValidators.validatePassword,
                onFieldSubmitted: (_) => _ctrl.login(context),
              ),
              const SizedBox(height: 12),
              LoginRememberMe(
                value: _ctrl.rememberMe,
                onChanged: _ctrl.toggleRememberMe,
                theme: theme,
                onForgotPassword: () => showDialog(
                  context: context,
                  builder: (_) => const ForgotPasswordDialog(),
                ),
              ),
              const SizedBox(height: 12),
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
              LoginActions(
                isLoading: _ctrl.isLoading,
                onLogin: () => _ctrl.login(context),
                onRegister: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const WebDocumentsRegister(),
                  ),
                ),
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

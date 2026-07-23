import 'package:flutter/material.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? usernameValidator;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? confirmPasswordValidator;

  const RegisterFormFields({
    super.key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.onFieldSubmitted,
    this.emailValidator,
    this.usernameValidator,
    this.passwordValidator,
    this.confirmPasswordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: emailValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: usernameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: usernameValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          validator: passwordValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            labelText: 'Conferma password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: onToggleConfirmPassword,
            ),
          ),
          validator: confirmPasswordValidator,
        ),
      ],
    );
  }
}

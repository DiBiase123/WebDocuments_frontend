import 'package:flutter/material.dart';

class ResetFormFields extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? confirmPasswordValidator;
  final void Function(String)? onFieldSubmitted;

  const ResetFormFields({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.passwordValidator,
    this.confirmPasswordValidator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Nuova Password',
            prefixIcon: const Icon(Icons.lock),
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
            labelText: 'Conferma Password',
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

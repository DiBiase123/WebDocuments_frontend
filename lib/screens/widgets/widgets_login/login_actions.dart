import 'package:flutter/material.dart';

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final ThemeData theme;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.onRegister,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ENTRA'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Non hai un account? ', style: theme.textTheme.bodySmall),
            GestureDetector(
              onTap: onRegister,
              child: Text(
                'Registrati',
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
    );
  }
}

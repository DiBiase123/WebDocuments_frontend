import 'package:flutter/material.dart';

class LoginRememberMe extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final ThemeData theme;
  final VoidCallback onForgotPassword;

  const LoginRememberMe({
    super.key,
    required this.value,
    required this.onChanged,
    required this.theme,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text('Ricordami', style: theme.textTheme.bodySmall),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onForgotPassword,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Password dimenticata?',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

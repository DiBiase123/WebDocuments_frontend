import 'package:flutter/material.dart';

class UsersRoleDropdown extends StatelessWidget {
  final String? role;
  final ValueChanged<String> onChanged;

  const UsersRoleDropdown({
    super.key,
    required this.role,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: role,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Ruolo',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      selectedItemBuilder: (context) => const [
        Text('USER', style: TextStyle(fontSize: 14)),
        Text('ADMIN', style: TextStyle(fontSize: 14)),
        Text('SUPER_ADMIN', style: TextStyle(fontSize: 14)),
      ],
      items: const [
        DropdownMenuItem(
          value: 'USER',
          child: Text('USER', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'ADMIN',
          child: Text('ADMIN', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'SUPER_ADMIN',
          child: Text('SUPER_ADMIN', style: TextStyle(fontSize: 14)),
        ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

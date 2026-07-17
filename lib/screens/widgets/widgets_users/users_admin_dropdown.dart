import 'package:flutter/material.dart';

class UsersAdminDropdown extends StatelessWidget {
  final String? adminId;
  final List<dynamic> admins;
  final ValueChanged<String?> onChanged;

  const UsersAdminDropdown({
    super.key,
    required this.adminId,
    required this.admins,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: adminId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Admin assegnato',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      selectedItemBuilder: (context) => <Widget>[
        const Text('Nessuno', style: TextStyle(fontSize: 14)),
        ...admins.map(
          (a) => Text(
            a['email'] ?? a['username'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Nessuno', style: TextStyle(fontSize: 14)),
        ),
        ...admins.map(
          (a) => DropdownMenuItem(
            value: a['id'],
            child: Text(
              a['email'] ?? a['username'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';

Future<String?> showEnteDialog(
  BuildContext context, {
  String? initialValue,
  bool isEdit = false,
}) async {
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final ctrl = TextEditingController(text: initialValue ?? '');
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Modifica ente' : 'Nuovo ente',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            decoration: InputDecoration(
              labelText: 'Nome ente',
              labelStyle: const TextStyle(fontSize: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(ctx).colorScheme.surface.withAlpha(100),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx, ctrl.text.trim());
            },
            child: Text(
              isEdit ? 'Salva' : 'Crea',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      );
    },
  );
}

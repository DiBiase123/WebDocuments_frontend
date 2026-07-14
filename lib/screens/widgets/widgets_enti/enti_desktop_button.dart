import 'package:flutter/material.dart';

class EntiDesktopButton extends StatelessWidget {
  final VoidCallback onAdd;

  const EntiDesktopButton({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 32),
            label: const Text('Crea ente', style: TextStyle(fontSize: 22)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
              foregroundColor: const Color(0xFFF08A5D),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}

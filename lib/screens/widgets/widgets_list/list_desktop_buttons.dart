import 'package:flutter/material.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';

class ListDesktopButtons extends StatelessWidget {
  final List<dynamic> docs;
  final bool ascending;
  final VoidCallback onToggleOrder;

  const ListDesktopButtons({
    super.key,
    required this.docs,
    required this.ascending,
    required this.onToggleOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => PdfByEnte(docs: docs))),
            icon: const Icon(Icons.business, size: 32),
            label: const Text('Enti', style: TextStyle(fontSize: 22)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
              foregroundColor: const Color(0xFFF08A5D),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: onToggleOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
              foregroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 28),
                const SizedBox(width: 8),
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  ascending ? 'Crescente' : 'Decrescente',
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/pdf_by_date.dart';

class DesktopButtons extends StatelessWidget {
  final List<dynamic> docs;
  const DesktopButtons({super.key, required this.docs});

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
          ElevatedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => PdfByDate(docs: docs))),
            icon: const Icon(Icons.calendar_month, size: 32),
            label: const Text('Date', style: TextStyle(fontSize: 22)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
              foregroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}

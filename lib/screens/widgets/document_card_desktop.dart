import 'package:flutter/material.dart';

class DocumentCardDesktop extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String formattedDate;
  final String enteNome;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const DocumentCardDesktop({
    super.key,
    required this.doc,
    required this.formattedDate,
    required this.enteNome,
    required this.onPreview,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nome file
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade200.withAlpha(30),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              doc['fileName'] ?? '',
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Corpo: descrizione
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              doc['description'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // Data + pulsanti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 22,
                  color: t.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.cyanAccent),
                  onPressed: onPreview,
                  tooltip: 'Anteprima',
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.greenAccent),
                  onPressed: onDownload,
                  tooltip: 'Download',
                ),
              ],
            ),
          ),
          // Footer: ente in badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF08A5D).withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                enteNome,
                style: const TextStyle(
                  color: Color(0xFFF08A5D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

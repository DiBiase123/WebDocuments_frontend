import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              doc['description'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: EnteBadge(nome: enteNome, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

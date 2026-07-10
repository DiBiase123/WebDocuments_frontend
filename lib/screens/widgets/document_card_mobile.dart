import 'package:flutter/material.dart';

class DocumentCardMobile extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String formattedDate;
  final String enteNome;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const DocumentCardMobile({
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
          // Zona 1: descrizione
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              doc['description'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // Zona 2 e 3: data e ente
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: t.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(formattedDate, style: t.textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Footer: 2 bottoni
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPreview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withAlpha(20),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.cyanAccent,
                      size: 28,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onDownload,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withAlpha(20),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.download,
                      color: Colors.greenAccent,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

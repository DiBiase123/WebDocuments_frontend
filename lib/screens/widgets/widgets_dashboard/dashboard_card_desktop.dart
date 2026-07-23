import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_ente_badge.dart';

class DashboardCardDesktop extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String formattedDate;
  final List<String> entiNomi;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DashboardCardDesktop({
    super.key,
    required this.doc,
    required this.formattedDate,
    required this.entiNomi,
    required this.onPreview,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.amber.shade200.withAlpha(30),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    doc['description'] ?? '',
                    style: t.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: entiNomi.isNotEmpty
                      ? Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: entiNomi
                              .map((n) => EnteBadge(nome: n, fontSize: 16))
                              .toList(),
                        )
                      : const SizedBox.shrink(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility,
                        color: Colors.cyanAccent,
                      ),
                      onPressed: onPreview,
                      tooltip: 'Anteprima',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.greenAccent,
                      ),
                      onPressed: onDownload,
                      tooltip: 'Download',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: onEdit,
                      tooltip: 'Modifica',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: onDelete,
                      tooltip: 'Elimina',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              doc['fileName'] ?? '',
              style: TextStyle(
                color: Colors.amber.shade200,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

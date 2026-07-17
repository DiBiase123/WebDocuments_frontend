import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class DashboardDocumentCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final void Function(Map<String, dynamic>) onPreview;
  final void Function(Map<String, dynamic>) onDownload;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;

  const DashboardDocumentCard({
    super.key,
    required this.doc,
    required this.onPreview,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  });

  String _fmt(String s) {
    try {
      final d = DateTime.parse(s);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final enti =
        (doc['enti'] as List?)
            ?.map((e) => e['ente']?['nome'] as String?)
            .where((n) => n != null)
            .cast<String>()
            .toList() ??
        [];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(doc['description'] ?? '', style: t.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: enti
                  .map((n) => EnteBadge(nome: n, fontSize: 14))
                  .toList(),
            ),
            const SizedBox(height: 4),
            Text(
              'Data: ${_fmt(doc['documentDate'] ?? '')}',
              style: t.textTheme.bodySmall,
            ),
            Text(
              'File: ${doc['fileName'] ?? ''}',
              style: TextStyle(color: Colors.amber.shade200, fontSize: 13),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.cyanAccent),
              onPressed: () => onPreview(doc),
              tooltip: 'Anteprima',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.greenAccent),
              onPressed: () => onDownload(doc),
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => onEdit(doc),
              tooltip: 'Modifica',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => onDelete(doc),
              tooltip: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }
}

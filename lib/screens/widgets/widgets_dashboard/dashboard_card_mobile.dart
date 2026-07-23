import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_ente_badge.dart';

class DashboardCardMobile extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String formattedDate;
  final List<String> entiNomi;
  final VoidCallback onPreview;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DashboardCardMobile({
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
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 4,
              children: [
                Text(
                  doc['description'] ?? '',
                  style: t.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entiNomi.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entiNomi
                        .map((n) => EnteBadge(nome: n, fontSize: 16))
                        .toList(),
                  ),
                if (entiNomi.isNotEmpty) const SizedBox(height: 10),
                Text(
                  doc['fileName'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFFFFC107),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Anteprima',
                  child: InkWell(
                    onTap: onPreview,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withAlpha(20),
                        border: Border.all(
                          color: Colors.cyanAccent.withAlpha(60),
                          width: 1,
                        ),
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
              ),
              Expanded(
                child: Tooltip(
                  message: 'Download',
                  child: InkWell(
                    onTap: onDownload,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withAlpha(20),
                        border: Border.all(
                          color: Colors.greenAccent.withAlpha(60),
                          width: 1,
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
              ),
              Expanded(
                child: Tooltip(
                  message: 'Modifica',
                  child: InkWell(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(20),
                        border: Border.all(
                          color: Colors.orange.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Tooltip(
                  message: 'Elimina',
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withAlpha(20),
                        border: Border.all(
                          color: Colors.redAccent.withAlpha(60),
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 28,
                      ),
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

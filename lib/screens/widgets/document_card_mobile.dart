import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class DocumentCardMobile extends StatelessWidget {
  final Map<String, dynamic> doc;
  final String formattedDate;
  final List<String> entiNomi;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const DocumentCardMobile({
    super.key,
    required this.doc,
    required this.formattedDate,
    required this.entiNomi,
    required this.onPreview,
    required this.onDownload,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    doc['fileName'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

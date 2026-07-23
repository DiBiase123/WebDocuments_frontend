import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_ente_badge.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_controller.dart';

class PdfEnteBody extends StatelessWidget {
  final PdfEnteController ctrl;
  final bool isMobile;

  const PdfEnteBody({super.key, required this.ctrl, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final keys = ctrl.sortedKeys;
    final grouped = ctrl.grouped;
    return Column(
      children: [
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 12, 32, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ordina per Ente :',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    ctrl.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 32,
                  ),
                  label: Text(
                    ctrl.ascending ? 'A-Z' : 'Z-A',
                    style: const TextStyle(fontSize: 22),
                  ),
                  onPressed: ctrl.toggleAscending,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                    foregroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (_, i) {
              final nome = keys[i];
              final docs = grouped[nome]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: EnteBadge(nome: nome, fontSize: 20),
                  ),
                  ...docs.map(
                    (d) => Card(
                      margin: const EdgeInsets.only(bottom: 8, left: 16),
                      child: ListTile(
                        title: Text(
                          d['fileName'] ?? '',
                          style: const TextStyle(color: Color(0xFFFFC107)),
                        ),
                        subtitle: Text(
                          d['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.cyanAccent,
                              ),
                              onPressed: () => ctrl.openPdf(d),
                              tooltip: 'Anteprima',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () => ctrl.downloadPdf(d),
                              tooltip: 'Download',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

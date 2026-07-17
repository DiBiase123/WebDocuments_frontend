import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_controller.dart';

class PdfDateBody extends StatelessWidget {
  final PdfDateController ctrl;
  final bool isMobile;

  const PdfDateBody({super.key, required this.ctrl, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final keys = ctrl.sortedKeys();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documenti per ${ctrl.sortByEnte ? 'ente' : 'data'} :',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        ctrl.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 32,
                      ),
                      label: Text(
                        ctrl.ascending ? 'Crescente' : 'Decrescente',
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
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: Icon(
                        ctrl.sortByEnte ? Icons.calendar_month : Icons.business,
                        size: 32,
                      ),
                      label: Text(
                        ctrl.sortByEnte ? 'Date' : 'Enti',
                        style: const TextStyle(fontSize: 22),
                      ),
                      onPressed: ctrl.toggleSortByEnte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
                        foregroundColor: const Color(0xFFF08A5D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (_, i) {
              final key = keys[i];
              final docs = ctrl.grouped[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ctrl.sortByEnte ? key : ctrl.monthName(key),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...docs.map(
                    (d) => Card(
                      margin: const EdgeInsets.only(bottom: 6, left: 16),
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
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

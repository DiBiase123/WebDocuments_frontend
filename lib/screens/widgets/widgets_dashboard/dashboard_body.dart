import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_users.dart';
import 'package:webdocuments/screens/webdocuments_enti.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_document_card.dart';

class DashboardBody extends StatelessWidget {
  final DashboardController ctrl;
  final bool isMobile;
  final ScrollController scrollController;

  const DashboardBody({
    super.key,
    required this.ctrl,
    required this.isMobile,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final docs = ctrl.filteredDocs;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Dashboard :',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isMobile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WebDocumentsEnti(),
                          ),
                        );
                        ctrl.load();
                      },
                      icon: const Icon(Icons.business, size: 32),
                      label: const Text('Enti', style: TextStyle(fontSize: 22)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
                        foregroundColor: const Color(0xFFF08A5D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WebDocumentsUsers(),
                        ),
                      ),
                      icon: const Icon(Icons.people, size: 32),
                      label: const Text(
                        'Utenti',
                        style: TextStyle(fontSize: 22),
                      ),
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
            ],
          ),
        ),
        Expanded(
          child: ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : ctrl.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ctrl.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: ctrl.load,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: t.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text('Nessun documento', style: t.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: ctrl.upload,
                        icon: const Icon(Icons.add),
                        label: const Text('Carica il primo documento'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => DashboardDocumentCard(
                    doc: docs[i],
                    isMobile: isMobile,
                    onPreview: ctrl.openPdf,
                    onDownload: ctrl.downloadPdf,
                    onEdit: ctrl.edit,
                    onDelete: ctrl.delete,
                  ),
                ),
        ),
      ],
    );
  }
}

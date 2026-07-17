import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_guard.dart';
import 'package:webdocuments/screens/webdocuments_enti.dart';
import 'package:webdocuments/screens/webdocuments_users.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/widgets/animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_footer.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_body.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_extract_fab.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_controller.dart';

class WebDocumentsDashboard extends StatefulWidget {
  const WebDocumentsDashboard({super.key});
  @override
  State<WebDocumentsDashboard> createState() => _WebDocumentsDashboardState();
}

class _WebDocumentsDashboardState extends State<WebDocumentsDashboard> {
  final _ctrl = DashboardController();
  final _extractCtrl = ExtractController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _extractCtrl.dispose();
    super.dispose();
  }

  void _showExtractedText(String text) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Testo estratto'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(text, style: const TextStyle(fontSize: 14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showExtractedData(
    Map<String, String> data,
    List<int> bytes,
    String fileName,
  ) {
    final descCtl = TextEditingController(text: data['description'] ?? '');
    final dateCtl = TextEditingController(text: data['documentDate'] ?? '');
    final enteCtl = TextEditingController(text: data['ente'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dati estratti con AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateCtl,
              decoration: const InputDecoration(labelText: 'Data (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: enteCtl,
              decoration: const InputDecoration(labelText: 'Ente'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _extractCtrl
                  .uploadWithData(
                    description: descCtl.text,
                    documentDate: dateCtl.text,
                    enteNome: enteCtl.text,
                    bytes: bytes,
                    fileName: fileName,
                  )
                  .then((_) {
                    _ctrl.load();
                  });
            },
            child: const Text('Crea documento'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return AuthGuard(
      allowedRoles: ['ADMIN', 'SUPER_ADMIN'],
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: true,
          child: DashboardAppBar(
            onUpload: _ctrl.upload,
            service: _ctrl.svc,
            searchController: TextEditingController(),
            onSearch: (v) {},
            isMobile: isMobile,
          ),
        ),
        body: DashboardBody(ctrl: _ctrl, isMobile: isMobile),
        floatingActionButton: DashboardExtractFab(
          onTextExtracted: _showExtractedText,
          onDataExtracted: _showExtractedData,
        ),
        bottomNavigationBar: isMobile
            ? DashboardFooter(
                onList: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WebDocumentsList()),
                ),
                onUpload: _ctrl.upload,
                onEnti: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WebDocumentsEnti()),
                  );
                  _ctrl.load();
                },
                onUtenti: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WebDocumentsUsers()),
                ),
              )
            : null,
      ),
    );
  }
}

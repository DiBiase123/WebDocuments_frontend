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

  void _showExtractedData(
    Map<String, String> data,
    List<int> bytes,
    String fileName,
  ) {
    _extractCtrl
        .uploadWithData(
          description: data['description'] ?? '',
          documentDate: data['documentDate'] ?? '',
          enteNome: data['ente'] ?? '',
          bytes: bytes,
          fileName: fileName,
        )
        .then((_) {
          _ctrl.load();
        });
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

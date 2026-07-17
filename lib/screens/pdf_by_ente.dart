import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_guard.dart';
import 'package:webdocuments/screens/widgets/animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_body.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_footer.dart';

class PdfByEnte extends StatefulWidget {
  final List<dynamic> docs;
  const PdfByEnte({super.key, required this.docs});

  @override
  State<PdfByEnte> createState() => _PdfByEnteState();
}

class _PdfByEnteState extends State<PdfByEnte> {
  late final PdfEnteController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PdfEnteController(widget.docs);
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return AuthGuard(
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: true,
          child: PdfEnteAppBar(ctrl: _ctrl, isMobile: isMobile),
        ),
        body: PdfEnteBody(ctrl: _ctrl, isMobile: isMobile),
        bottomNavigationBar: isMobile ? PdfEnteFooter(ctrl: _ctrl) : null,
      ),
    );
  }
}

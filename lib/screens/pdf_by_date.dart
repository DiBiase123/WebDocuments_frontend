import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_guard.dart';
import 'package:webdocuments/screens/widgets/animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_controller.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_body.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_footer.dart';

class PdfByDate extends StatefulWidget {
  final List<dynamic> docs;
  const PdfByDate({super.key, required this.docs});

  @override
  State<PdfByDate> createState() => _PdfByDateState();
}

class _PdfByDateState extends State<PdfByDate> {
  late final PdfDateController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PdfDateController(widget.docs);
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
          child: PdfDateAppBar(
            title: _ctrl.sortByEnte
                ? 'Documenti per ente'
                : 'Documenti per data',
          ),
        ),
        body: PdfDateBody(ctrl: _ctrl, isMobile: isMobile),
        bottomNavigationBar: isMobile ? PdfDateFooter(ctrl: _ctrl) : null,
      ),
    );
  }
}

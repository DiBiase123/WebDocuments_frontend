import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_app_bar.dart';
import 'package:webdocuments/screens/widgets/document_card_mobile.dart';
import 'package:webdocuments/screens/widgets/document_card_desktop.dart';

class WebDocumentsList extends StatefulWidget {
  const WebDocumentsList({super.key});
  @override
  State<WebDocumentsList> createState() => _WebDocumentsListState();
}

class _WebDocumentsListState extends State<WebDocumentsList> {
  final _svc = WebDocumentsService();
  final _pdf = PdfHelper(AuthStorage());
  final _auth = AuthStorage();
  final _searchCtl = TextEditingController();
  List<dynamic> _docs = [];
  bool _loading = true;
  String? _error;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkAdmin();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final docs = await _svc.getDocuments();
      if (mounted) {
        setState(() {
          _docs = docs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento';
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkAdmin() async {
    final auth = await _auth.loadAuthData();
    if (auth == null) {
      return;
    }
    final parts = auth['token']!.split('.');
    if (parts.length == 3) {
      final payload = jsonDecode(
        utf8.decode(base64.decode(base64.normalize(parts[1]))),
      );
      if (mounted) {
        setState(() {
          _isAdmin = payload['role'] == 'ADMIN';
        });
      }
    }
  }

  String _fmt(String s) {
    try {
      final d = DateTime.parse(s);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: ListAppBar(
        service: _svc,
        searchController: _searchCtl,
        isAdmin: _isAdmin,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            )
          : _docs.isEmpty
          ? Center(
              child: Text('Nessun documento', style: t.textTheme.bodyMedium),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _docs.length,
              itemBuilder: (_, i) {
                final d = _docs[i];
                if (isMobile) {
                  return DocumentCardMobile(
                    doc: d,
                    formattedDate: _fmt(d['documentDate'] ?? ''),
                    enteNome: d['ente']?['nome'] ?? '',
                    onPreview: () {
                      _pdf.open(d);
                    },
                    onDownload: () {
                      _pdf.download(d);
                    },
                  );
                }
                return DocumentCardDesktop(
                  doc: d,
                  formattedDate: _fmt(d['documentDate'] ?? ''),
                  enteNome: d['ente']?['nome'] ?? '',
                  onPreview: () {
                    _pdf.open(d);
                  },
                  onDownload: () {
                    _pdf.download(d);
                  },
                );
              },
            ),
    );
  }
}

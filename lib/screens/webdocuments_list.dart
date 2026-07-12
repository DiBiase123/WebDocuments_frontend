import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/pdf_by_date.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_app_bar.dart';
import 'package:webdocuments/screens/widgets/list_footer.dart';
import 'package:webdocuments/screens/widgets/desktop_buttons.dart';
import 'package:webdocuments/screens/widgets/document_card_mobile.dart';
import 'package:webdocuments/screens/widgets/document_card_desktop.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';

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
  final _scrollCtl = ScrollController();
  List<dynamic> _docs = [], _filtered = [];
  bool _loading = true, _showAppBar = true, _isAdmin = false;
  String? _error;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _scrollCtl.addListener(() {
      final o = _scrollCtl.offset;
      if ((o > _lastOffset && o > 70 && _showAppBar) ||
          (o < _lastOffset && !_showAppBar)) {
        setState(() => _showAppBar = !_showAppBar);
      }
      _lastOffset = o;
    });
  }

  Future<void> _checkAuth() async {
    if (await _auth.loadAuthData() == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
        );
      }
      return;
    }
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
        docs.sort(
          (a, b) =>
              (b['documentDate'] ?? '').compareTo(a['documentDate'] ?? ''),
        );
        setState(() {
          _docs = docs;
          _filtered = docs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Errore caricamento';
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkAdmin() async {
    final a = await _auth.loadAuthData();
    if (a == null) {
      return;
    }
    final p = a['token']!.split('.');
    if (p.length != 3) {
      return;
    }
    final d = jsonDecode(utf8.decode(base64.decode(base64.normalize(p[1]))));
    if (mounted) {
      setState(() => _isAdmin = d['role'] == 'ADMIN');
    }
  }

  void _onSearch(String q) {
    final f = q.toLowerCase();
    setState(
      () => _filtered = f.isEmpty
          ? _docs
          : _docs
                .where(
                  (d) =>
                      '${d['fileName'] ?? ''} ${d['description'] ?? ''} ${(d['enti'] as List?)?.map((e) => e['ente']?['nome'] ?? '').join(' ') ?? ''}'
                          .toLowerCase()
                          .contains(f),
                )
                .toList(),
    );
  }

  String _fmt(String s) {
    try {
      final d = DateTime.parse(s);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return s;
    }
  }

  List<String> _entiNomi(Map<String, dynamic> d) =>
      (d['enti'] as List?)
          ?.map((e) => e['ente']?['nome'] as String?)
          .where((n) => n != null)
          .cast<String>()
          .toList() ??
      [];

  @override
  void dispose() {
    _searchCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showAppBar ? 70 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showAppBar ? 70 : 0,
          child: _showAppBar
              ? ListAppBar(
                  onSearch: _onSearch,
                  service: _svc,
                  searchController: _searchCtl,
                  isAdmin: _isAdmin,
                  isMobile: isMobile,
                  onDashboard: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const WebDocumentsDashboard(),
                    ),
                  ),
                  onEnte: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PdfByEnte(docs: _docs)),
                  ),
                  onDate: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PdfByDate(docs: _docs)),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Column(
        children: [
          if (!isMobile) DesktopButtons(docs: _docs),
          Expanded(
            child: _loading
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
                : _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Nessun documento',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final d = _filtered[i], en = _entiNomi(d);
                      return isMobile
                          ? DocumentCardMobile(
                              doc: d,
                              formattedDate: _fmt(d['documentDate'] ?? ''),
                              entiNomi: en,
                              onPreview: () => _pdf.open(d),
                              onDownload: () => _pdf.download(d),
                            )
                          : DocumentCardDesktop(
                              doc: d,
                              formattedDate: _fmt(d['documentDate'] ?? ''),
                              entiNomi: en,
                              onPreview: () => _pdf.open(d),
                              onDownload: () => _pdf.download(d),
                            );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? ListFooter(docs: _docs, isAdmin: _isAdmin)
          : null,
    );
  }
}

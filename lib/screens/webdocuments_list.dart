import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_footer.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_page_body.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_card_builder.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_app_bar_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_app_bar_mobile.dart';
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
  bool _loading = true,
      _showAppBar = true,
      _isAdmin = false,
      _ascending = false;
  String? _error;
  double _lastOffset = 0;
  late final ListCardBuilder _cardBuilder;

  @override
  void initState() {
    super.initState();
    _cardBuilder = ListCardBuilder(
      onPreview: (d) => _pdf.open(d),
      onDownload: (d) => _pdf.download(d),
    );
    _checkAuth();
    _scrollCtl.addListener(() {
      final o = _scrollCtl.offset;
      if (o <= 0) {
        if (!_showAppBar) setState(() => _showAppBar = true);
      } else if ((o > _lastOffset && o > 70 && _showAppBar) ||
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
        _sort(docs);
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

  void _sort(List<dynamic> docs) => docs.sort(
    (a, b) => _ascending
        ? (a['documentDate'] ?? '').compareTo(b['documentDate'] ?? '')
        : (b['documentDate'] ?? '').compareTo(a['documentDate'] ?? ''),
  );
  void _toggleOrder() {
    setState(() {
      _ascending = !_ascending;
      _sort(_docs);
      _filtered = _docs;
    });
  }

  Future<void> _checkAdmin() async {
    final a = await _auth.loadAuthData();
    if (a == null) return;
    final p = a['token']!.split('.');
    if (p.length != 3) return;
    final d = jsonDecode(utf8.decode(base64.decode(base64.normalize(p[1]))));
    if (mounted) {
      setState(
        () => _isAdmin = d['role'] == 'ADMIN' || d['role'] == 'SUPER_ADMIN',
      );
    }
    if (!_showAppBar) {
      setState(() => _showAppBar = true);
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
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showAppBar ? 1.0 : 0.0,
          child: SizedBox(
            height: 70,
            child: isMobile
                ? ListAppBarMobile(
                    searchController: _searchCtl,
                    onSearch: _onSearch,
                    service: _svc,
                  )
                : ListAppBarDesktop(
                    searchController: _searchCtl,
                    onSearch: _onSearch,
                    isAdmin: _isAdmin,
                    onDashboard: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsDashboard(),
                      ),
                    ),
                    service: _svc,
                  ),
          ),
        ),
      ),
      body: ListPageBody(
        loading: _loading,
        error: _error,
        documents: _filtered,
        isMobile: isMobile,
        showAppBar: _showAppBar,
        ascending: _ascending,
        cardBuilder: _cardBuilder,
        scrollController: _scrollCtl,
        onRetry: _load,
        onToggleOrder: _toggleOrder,
        docs: _docs,
      ),
      bottomNavigationBar: isMobile
          ? ListFooter(
              docs: _docs,
              isAdmin: _isAdmin,
              ascending: _ascending,
              onToggleOrder: _toggleOrder,
            )
          : null,
    );
  }
}

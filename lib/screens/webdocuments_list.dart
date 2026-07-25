import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdocuments/services/webdocuments_auth_storage.dart';
import 'package:webdocuments/services/webdocuments_auth_guard.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_pdf_helper.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_footer.dart';
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
  final _auth = AuthStorage();
  late final _pdf = PdfHelper(_auth);
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  List<dynamic> _docs = [], _filtered = [];
  bool _loading = true, _isAdmin = false, _ascending = false;
  String? _error;
  double _appBarOpacity = 1.0;
  late final ListCardBuilder _cardBuilder;

  @override
  void initState() {
    super.initState();
    _cardBuilder = ListCardBuilder(
      onPreview: (d) => _pdf.open(d),
      onDownload: (d) => _pdf.download(d),
    );
    _loadPreferences();
    _load();
    _checkAdmin();
    _scrollCtl.addListener(() {
      final o = _scrollCtl.offset;
      double newOpacity = 1.0 - (o / 200);
      if (newOpacity < 0.0) newOpacity = 0.0;
      if (newOpacity > 1.0) newOpacity = 1.0;
      if (newOpacity != _appBarOpacity) {
        setState(() => _appBarOpacity = newOpacity);
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final ascending = prefs.getBool('list_ascending') ?? false;
    _ascending = ascending;
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

  void _toggleOrder() async {
    setState(() {
      _ascending = !_ascending;
      _sort(_docs);
      _filtered = _docs;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('list_ascending', _ascending);
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
    return AuthGuard(
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: _appBarOpacity > 0,
          opacity: _appBarOpacity,
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
        body: ListPageBody(
          loading: _loading,
          error: _error,
          documents: _filtered,
          isMobile: isMobile,
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
      ),
    );
  }
}

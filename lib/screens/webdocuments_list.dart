import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_app_bar.dart';
import 'package:webdocuments/screens/widgets/list_footer.dart';
import 'package:webdocuments/screens/widgets/month_section.dart';
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
  bool _loading = true,
      _showAppBar = true,
      _isAdmin = false,
      _ascending = false;
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

  void _sort(List<dynamic> docs) {
    docs.sort(
      (a, b) => _ascending
          ? (a['documentDate'] ?? '').compareTo(b['documentDate'] ?? '')
          : (b['documentDate'] ?? '').compareTo(a['documentDate'] ?? ''),
    );
  }

  void _toggleOrder() {
    setState(() {
      _ascending = !_ascending;
      _sort(_docs);
      _filtered = _docs;
    });
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

  String _monthLabel(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'Gen',
        'Feb',
        'Mar',
        'Apr',
        'Mag',
        'Giu',
        'Lug',
        'Ago',
        'Set',
        'Ott',
        'Nov',
        'Dic',
      ];
      return '${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
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

    final grouped = <String, List<dynamic>>{};
    for (final d in _filtered) {
      final m = _monthLabel(d['documentDate'] ?? '');
      grouped.putIfAbsent(m, () => []).add(d);
    }
    final months = grouped.keys.toList();
    months.sort((a, b) => _ascending ? a.compareTo(b) : b.compareTo(a));

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
                  onDate: _toggleOrder,
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Column(
        children: [
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PdfByEnte(docs: _docs)),
                    ),
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
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _toggleOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                      foregroundColor: const Color(0xFF4ECDC4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 28),
                        const SizedBox(width: 8),
                        Icon(
                          _ascending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _ascending ? 'Crescente' : 'Decrescente',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    itemCount: months.length,
                    itemBuilder: (_, i) {
                      final m = months[i];
                      final cards = grouped[m]!.map((d) {
                        final en = _entiNomi(d);
                        final card = isMobile
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: card,
                        );
                      }).toList();
                      return MonthSection(
                        month: m,
                        docCount: cards.length,
                        cards: cards,
                      );
                    },
                  ),
          ),
        ],
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

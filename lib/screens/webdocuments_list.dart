import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdocuments/services/webdocuments_auth_storage.dart';
import 'package:webdocuments/services/webdocuments_auth_guard.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_pdf_helper.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_footer.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_card_builder.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_helpers.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_month_section.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_app_bar_mobile.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_app_bar_desktop.dart';

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
      double newOpacity = 1.0 - (o / 120);
      newOpacity = newOpacity.clamp(0.0, 1.0);
      if (newOpacity != _appBarOpacity) {
        setState(() => _appBarOpacity = newOpacity);
      }
    });
  }

  void _resetAppBar() {
    if (!_scrollCtl.hasClients) return;
    if (_scrollCtl.position.maxScrollExtent <= 0 || _scrollCtl.offset <= 0) {
      if (_appBarOpacity != 1.0) {
        setState(() => _appBarOpacity = 1.0);
      }
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _ascending = prefs.getBool('list_ascending') ?? false;
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
    _scrollCtl.jumpTo(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('list_ascending', _ascending);
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
    _scrollCtl.jumpTo(0);
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final showScrollbar =
        !_loading && _error == null && _filtered.isNotEmpty && !isDesktop;
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetAppBar());
    return AuthGuard(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70 * _appBarOpacity),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            opacity: _appBarOpacity,
            child: SizedBox(
              height: 70,
              child: isDesktop
                  ? ListAppBarDesktop(
                      searchController: _searchCtl,
                      onSearch: _onSearch,
                      isAdmin: _isAdmin,
                      onDashboard: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const WebDocumentsDashboard(),
                        ),
                      ),
                      service: _svc,
                    )
                  : ListAppBarMobile(
                      searchController: _searchCtl,
                      onSearch: _onSearch,
                      service: _svc,
                    ),
            ),
          ),
        ),
        body: showScrollbar
            ? Scrollbar(
                controller: _scrollCtl,
                thumbVisibility: true,
                child: _buildBody(isDesktop),
              )
            : _buildBody(isDesktop),
        bottomNavigationBar: isDesktop
            ? null
            : ListFooter(
                docs: _docs,
                isAdmin: _isAdmin,
                ascending: _ascending,
                onToggleOrder: _toggleOrder,
              ),
      ),
    );
  }

  Widget _buildBody(bool isDesktop) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 60),
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
                    : _buildGroupedList(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 32,
                  top: 16,
                  bottom: 16,
                  right: 32,
                ),
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Lista dei documenti :',
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                    if (isDesktop)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfByEnte(docs: _docs),
                              ),
                            ),
                            icon: const Icon(Icons.business, size: 32),
                            label: const Text(
                              'Enti',
                              style: TextStyle(fontSize: 22),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF08A5D,
                              ).withAlpha(30),
                              foregroundColor: const Color(0xFFF08A5D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _toggleOrder,
                            icon: const Icon(Icons.schedule, size: 32),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF4ECDC4,
                              ).withAlpha(30),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedList() {
    final grouped = <String, List<dynamic>>{};
    for (final d in _filtered) {
      grouped
          .putIfAbsent(
            ListHelpers.monthLabel(d['documentDate'] ?? ''),
            () => [],
          )
          .add(d);
    }
    final months = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]!.first['documentDate'] ?? '';
        final dateB = grouped[b]!.first['documentDate'] ?? '';
        return _ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollCtl,
        padding: const EdgeInsets.all(16),
        itemCount: months.length,
        itemBuilder: (_, i) {
          final m = months[i];
          final cards = grouped[m]!
              .map((d) => _cardBuilder.build(d, true))
              .toList();
          return MonthSection(
            month: m,
            docCount: cards.length,
            cards: cards,
            sectionKey: GlobalKey(),
            onToggle: _resetAppBar,
          );
        },
      ),
    );
  }
}

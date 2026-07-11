import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/pdf_by_date.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_app_bar.dart';
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
  List<dynamic> _docs = [];
  List<dynamic> _filteredDocs = [];
  bool _loading = true;
  String? _error;
  bool _isAdmin = false;
  bool _showAppBar = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _scrollCtl.addListener(() {
      final offset = _scrollCtl.offset;
      if (offset > _lastOffset && offset > 70 && _showAppBar) {
        setState(() => _showAppBar = false);
      } else if (offset < _lastOffset && !_showAppBar) {
        setState(() => _showAppBar = true);
      }
      _lastOffset = offset;
    });
  }

  Future<void> _checkAuth() async {
    final auth = await _auth.loadAuthData();
    if (auth == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
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
          _filteredDocs = docs;
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
      final p = jsonDecode(
        utf8.decode(base64.decode(base64.normalize(parts[1]))),
      );
      if (mounted) {
        setState(() {
          _isAdmin = p['role'] == 'ADMIN';
        });
      }
    }
  }

  void _onSearch(String q) {
    final f = q.toLowerCase();
    setState(() {
      _filteredDocs = f.isEmpty
          ? _docs
          : _docs.where((d) {
              return (d['fileName'] ?? '').toLowerCase().contains(f) ||
                  (d['description'] ?? '').toLowerCase().contains(f) ||
                  ((d['enti'] as List?)
                              ?.map((e) => e['ente']?['nome'] ?? '')
                              .join(' ') ??
                          '')
                      .toLowerCase()
                      .contains(f);
            }).toList();
    });
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
                  onDashboard: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsDashboard(),
                      ),
                    );
                  },
                  onEnte: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PdfByEnte(docs: _docs)),
                    );
                  },
                  onDate: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PdfByDate(docs: _docs)),
                    );
                  },
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfByEnte(docs: _docs),
                        ),
                      );
                    },
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
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfByDate(docs: _docs),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month, size: 32),
                    label: const Text('Date', style: TextStyle(fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                      foregroundColor: const Color(0xFF4ECDC4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 18,
                      ),
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
                : _filteredDocs.isEmpty
                ? const Center(
                    child: Text(
                      'Nessun documento',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDocs.length,
                    itemBuilder: (_, i) {
                      final d = _filteredDocs[i];
                      final entiNomi = _entiNomi(d);
                      return isMobile
                          ? DocumentCardMobile(
                              doc: d,
                              formattedDate: _fmt(d['documentDate'] ?? ''),
                              entiNomi: entiNomi,
                              onPreview: () {
                                _pdf.open(d);
                              },
                              onDownload: () {
                                _pdf.download(d);
                              },
                            )
                          : DocumentCardDesktop(
                              doc: d,
                              formattedDate: _fmt(d['documentDate'] ?? ''),
                              entiNomi: entiNomi,
                              onPreview: () {
                                _pdf.open(d);
                              },
                              onDownload: () {
                                _pdf.download(d);
                              },
                            );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              width: double.infinity,
              height: 50,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: InkWell(
                          splashColor: const Color(0xFFF08A5D).withAlpha(60),
                          highlightColor: const Color(0xFFF08A5D).withAlpha(30),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfByEnte(docs: _docs),
                              ),
                            );
                          },
                          child: const SizedBox.expand(
                            child: Icon(
                              Icons.business,
                              color: Color(0xFFF08A5D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: InkWell(
                          splashColor: const Color(0xFF4ECDC4).withAlpha(60),
                          highlightColor: const Color(0xFF4ECDC4).withAlpha(30),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfByDate(docs: _docs),
                              ),
                            );
                          },
                          child: const SizedBox.expand(
                            child: Icon(
                              Icons.calendar_month,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: InkWell(
                            splashColor: const Color(0xFFE43F5A).withAlpha(60),
                            highlightColor: const Color(
                              0xFFE43F5A,
                            ).withAlpha(30),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const WebDocumentsDashboard(),
                                ),
                              );
                            },
                            child: const SizedBox.expand(
                              child: Icon(
                                Icons.dashboard,
                                color: Color(0xFFE43F5A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
    );
  }
}

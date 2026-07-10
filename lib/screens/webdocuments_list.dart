import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/list_app_bar.dart';

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
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['fileName'] ?? '',
                                style: t.textTheme.titleMedium?.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                d['description'] ?? '',
                                style: t.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: t.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _fmt(d['documentDate'] ?? ''),
                                    style: t.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF08A5D,
                                      ).withAlpha(50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      d['ente']?['nome'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFF08A5D),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.cyanAccent,
                              ),
                              onPressed: () {
                                _pdf.open(d);
                              },
                              tooltip: 'Anteprima',
                            ),
                            const SizedBox(height: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () {
                                _pdf.download(d);
                              },
                              tooltip: 'Download',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

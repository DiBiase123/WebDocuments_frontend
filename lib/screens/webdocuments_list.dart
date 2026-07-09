import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';

class WebDocumentsList extends StatefulWidget {
  const WebDocumentsList({super.key});
  @override
  State<WebDocumentsList> createState() => _WebDocumentsListState();
}

class _WebDocumentsListState extends State<WebDocumentsList> {
  final WebDocumentsService _service = WebDocumentsService();
  final AuthStorage _authStorage = AuthStorage();
  List<dynamic> _documents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final documents = await _service.getDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Errore nel caricamento documenti';
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _isAdmin() async {
    final authData = await _authStorage.loadAuthData();
    if (authData == null) return false;
    final parts = authData['token']!.split('.');
    if (parts.length == 3) {
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = jsonDecode(decoded);
      return payloadMap['role'] == 'ADMIN';
    }
    return false;
  }

  Future<String> _getPdfUrl(
    Map<String, dynamic> doc, {
    bool download = false,
  }) async {
    final authData = await _authStorage.loadAuthData();
    final baseUrl = Config.buildUrl();
    final url =
        '$baseUrl/api/webdocuments/download/${doc['fileName']}?token=${authData?['token'] ?? ''}';
    if (download) {
      return '$url&download=true';
    }
    return url;
  }

  Future<void> _openPdf(Map<String, dynamic> doc) async {
    final url = await _getPdfUrl(doc);
    if (!mounted) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _downloadPdf(Map<String, dynamic> doc) async {
    final url = await _getPdfUrl(doc, download: true);
    if (!mounted) return;
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', doc['fileName'] ?? 'document.pdf')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebDocuments'),
        centerTitle: true,
        actions: [
          FutureBuilder<bool>(
            future: _isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.dashboard),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const WebDocumentsDashboard(),
                    ),
                  ),
                  tooltip: 'Dashboard',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _isLoading
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
                    onPressed: _loadDocuments,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            )
          : _documents.isEmpty
          ? Center(
              child: Text(
                'Nessun documento',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Contenuto principale
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titolo: Nome file (grande)
                              Text(
                                doc['fileName'] ?? '',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Descrizione
                              Text(
                                doc['description'] ?? '',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 10),
                              // Data e Badge Ente
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(doc['documentDate'] ?? ''),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF08A5D,
                                      ).withAlpha(50),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      doc['ente'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFF08A5D),
                                        fontSize: 18,
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
                        // Icone azione
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.cyanAccent,
                              ),
                              onPressed: () => _openPdf(doc),
                              tooltip: 'Anteprima',
                            ),
                            const SizedBox(height: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.greenAccent,
                              ),
                              onPressed: () => _downloadPdf(doc),
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

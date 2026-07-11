import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class PdfByEnte extends StatefulWidget {
  final List<dynamic> docs;
  const PdfByEnte({super.key, required this.docs});
  @override
  State<PdfByEnte> createState() => _PdfByEnteState();
}

class _PdfByEnteState extends State<PdfByEnte> {
  final _auth = AuthStorage();
  bool _ascending = true;

  Future<void> _openPdf(Map<String, dynamic> d) async {
    final auth = await _auth.loadAuthData();
    final url =
        '${Config.buildUrl()}/api/webdocuments/${d['id']}/download?token=${auth?['token'] ?? ''}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _downloadPdf(Map<String, dynamic> d) async {
    final auth = await _auth.loadAuthData();
    final url =
        '${Config.buildUrl()}/api/webdocuments/${d['id']}/download?token=${auth?['token'] ?? ''}&download=true';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', d['fileName'] ?? 'document.pdf')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<dynamic>> grouped = {};
    for (final d in widget.docs) {
      final enti =
          (d['enti'] as List?)
              ?.map((e) => e['ente']?['nome'] as String?)
              .where((n) => n != null)
              .cast<String>()
              .toList() ??
          ['Senza ente'];
      for (final nome in enti) {
        grouped.putIfAbsent(nome, () => []).add(d);
      }
    }
    final sortedKeys = grouped.keys.toList()..sort();
    if (!_ascending) sortedKeys.sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Documenti per ente')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 20,
                  ),
                  label: Text(_ascending ? 'A-Z' : 'Z-A'),
                  onPressed: () {
                    setState(() {
                      _ascending = !_ascending;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                    foregroundColor: const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (_, i) {
                final nome = sortedKeys[i];
                final docs = grouped[nome]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: EnteBadge(nome: nome, fontSize: 20),
                    ),
                    ...docs.map(
                      (d) => Card(
                        margin: const EdgeInsets.only(bottom: 8, left: 16),
                        child: ListTile(
                          title: Text(
                            d['fileName'] ?? '',
                            style: const TextStyle(color: Color(0xFFFFC107)),
                          ),
                          subtitle: Text(
                            d['description'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.cyanAccent,
                                ),
                                onPressed: () {
                                  _openPdf(d);
                                },
                                tooltip: 'Anteprima',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.greenAccent,
                                ),
                                onPressed: () {
                                  _downloadPdf(d);
                                },
                                tooltip: 'Download',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class PdfByEnte extends StatefulWidget {
  final List<dynamic> docs;
  const PdfByEnte({super.key, required this.docs});
  @override
  State<PdfByEnte> createState() => _PdfByEnteState();
}

class _PdfByEnteState extends State<PdfByEnte> {
  final _auth = AuthStorage();
  final _searchCtl = TextEditingController();
  bool _ascending = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = await _auth.loadAuthData();
    if (auth == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
    }
  }

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
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
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
        if (_searchQuery.isNotEmpty &&
            !nome.toLowerCase().contains(_searchQuery)) {
          continue;
        }
        grouped.putIfAbsent(nome, () => []).add(d);
      }
    }
    final sortedKeys = grouped.keys.toList()..sort();
    if (!_ascending) sortedKeys.sort((a, b) => b.compareTo(a));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            snap: false,
            title: SizedBox(
              height: 36,
              child: TextField(
                controller: _searchCtl,
                onChanged: (v) {
                  setState(() {
                    _searchQuery = v.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Cerca ente...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                },
                tooltip: _ascending ? 'A-Z' : 'Z-A',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.builder(
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

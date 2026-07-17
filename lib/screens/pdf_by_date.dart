import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/auth_guard.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/widgets/animated_app_bar.dart';

class PdfByDate extends StatefulWidget {
  final List<dynamic> docs;
  const PdfByDate({super.key, required this.docs});

  @override
  State<PdfByDate> createState() => _PdfByDateState();
}

class _PdfByDateState extends State<PdfByDate> {
  late List<dynamic> _sorted;
  late Map<String, List<dynamic>> _grouped;
  bool _ascending = false;
  bool _sortByEnte = false;
  final _auth = AuthStorage();

  @override
  void initState() {
    super.initState();
    _sort();
  }

  void _sort() {
    _sorted = List.from(widget.docs);
    if (_sortByEnte) {
      _sorted.sort((a, b) {
        final ea =
            (a['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] ?? '')
                .join(',') ??
            '';
        final eb =
            (b['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] ?? '')
                .join(',') ??
            '';
        return _ascending ? ea.compareTo(eb) : eb.compareTo(ea);
      });
      _grouped = {};
      for (final d in _sorted) {
        final enti =
            (d['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] as String?)
                .where((n) => n != null)
                .cast<String>()
                .join(', ') ??
            'Senza ente';
        _grouped.putIfAbsent(enti, () => []).add(d);
      }
    } else {
      _sorted.sort((a, b) {
        final da = a['documentDate'] ?? '';
        final db = b['documentDate'] ?? '';
        return _ascending ? da.compareTo(db) : db.compareTo(da);
      });
      _grouped = {};
      for (final d in _sorted) {
        final date = d['documentDate'] ?? '';
        final month = date.length >= 7 ? date.substring(0, 7) : 'Sconosciuto';
        _grouped.putIfAbsent(month, () => []).add(d);
      }
    }
    setState(() {});
  }

  String _monthName(String yyyymm) {
    try {
      final parts = yyyymm.split('-');
      if (parts.length != 2) return yyyymm;
      final m = int.parse(parts[1]), y = parts[0];
      const months = [
        '',
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
      return '${months[m]} $y';
    } catch (_) {
      return yyyymm;
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
  Widget build(BuildContext context) {
    final sortedKeys = _grouped.keys.toList();
    if (!_ascending) {
      sortedKeys.sort((a, b) => b.compareTo(a));
    } else {
      sortedKeys.sort();
    }
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AuthGuard(
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: true,
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              _sortByEnte ? 'Documenti per ente' : 'Documenti per data',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Indietro',
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () async {
                    await _auth.clearAuthData();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsLogin(),
                      ),
                    );
                  },
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Documenti per ${_sortByEnte ? 'ente' : 'data'} :',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!isMobile)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(
                            _ascending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 32,
                          ),
                          label: Text(
                            _ascending ? 'Crescente' : 'Decrescente',
                            style: const TextStyle(fontSize: 22),
                          ),
                          onPressed: () => setState(() {
                            _ascending = !_ascending;
                            _sort();
                          }),
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
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: Icon(
                            _sortByEnte ? Icons.calendar_month : Icons.business,
                            size: 32,
                          ),
                          label: Text(
                            _sortByEnte ? 'Date' : 'Enti',
                            style: const TextStyle(fontSize: 22),
                          ),
                          onPressed: () => setState(() {
                            _sortByEnte = !_sortByEnte;
                            _sort();
                          }),
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
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                itemBuilder: (_, i) {
                  final key = sortedKeys[i];
                  final docs = _grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _sortByEnte ? key : _monthName(key),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...docs.map(
                        (d) => Card(
                          margin: const EdgeInsets.only(bottom: 6, left: 16),
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
                                  onPressed: () => _openPdf(d),
                                  tooltip: 'Anteprima',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.greenAccent,
                                  ),
                                  onPressed: () => _downloadPdf(d),
                                  tooltip: 'Download',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: isMobile
            ? Container(
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
                            onTap: () => Navigator.pop(context),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back,
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
                            onTap: () => setState(() {
                              _ascending = !_ascending;
                              _sort();
                            }),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _ascending
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 22,
                                    color: const Color(0xFF4ECDC4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _ascending ? 'Crescente' : 'Decrescente',
                                    style: const TextStyle(
                                      color: Color(0xFF4ECDC4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() {
                            _sortByEnte = !_sortByEnte;
                            _sort();
                          }),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _sortByEnte
                                      ? Icons.calendar_month
                                      : Icons.business,
                                  size: 22,
                                  color: const Color(0xFFF08A5D),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _sortByEnte ? 'Date' : 'Enti',
                                  style: const TextStyle(
                                    color: Color(0xFFF08A5D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

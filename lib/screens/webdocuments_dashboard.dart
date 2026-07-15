import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/webdocuments_users.dart';
import 'package:webdocuments/screens/webdocuments_enti.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/document_form_dialog.dart';
import 'package:webdocuments/screens/widgets/dashboard_app_bar.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class WebDocumentsDashboard extends StatefulWidget {
  const WebDocumentsDashboard({super.key});
  @override
  State<WebDocumentsDashboard> createState() => _WebDocumentsDashboardState();
}

class _WebDocumentsDashboardState extends State<WebDocumentsDashboard> {
  final _svc = WebDocumentsService();
  final _pdf = PdfHelper(AuthStorage());
  final _auth = AuthStorage();
  List<dynamic> _docs = [];
  bool _loading = true;
  String? _error;

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
      return;
    }
    // Controlla ruolo
    if (auth!['role'] != 'ADMIN' && auth['role'] != 'SUPER_ADMIN') {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WebDocumentsList()),
        );
      }
      return;
    }
    if (mounted) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
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

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<Map<String, dynamic>?> _form([Map<String, dynamic>? doc]) {
    List<String>? enteIds;
    if (doc?['enti'] != null) {
      enteIds = (doc!['enti'] as List)
          .map((e) => e['ente']?['id'] as String)
          .toList();
    } else if (doc?['enteId'] != null) {
      enteIds = [doc!['enteId'] as String];
    }
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DocumentFormDialog(
        initialDescription: doc?['description'],
        initialDate: doc?['documentDate'],
        initialEnteIds: enteIds,
      ),
    );
  }

  Future<void> _upload() async {
    final form = await _form();
    if (form == null) {
      return;
    }
    final file = form['file'] as PlatformFile?;
    if (file == null || file.bytes == null) {
      return;
    }
    try {
      await _svc.createDocument(
        description: form['description']!,
        documentDate: form['documentDate']!,
        enteIds: (form['enteIds'] as List).cast<String>(),
        fileBytes: file.bytes!,
        fileName: file.name,
      );
      if (mounted) {
        _snack('Caricato');
        _load();
      }
    } catch (e) {
      if (mounted) {
        _snack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _edit(Map<String, dynamic> d) async {
    final form = await _form(d);
    if (form == null) {
      return;
    }
    try {
      await _svc.updateDocument(
        id: d['id'],
        description: form['description'],
        documentDate: form['documentDate'],
        enteIds: (form['enteIds'] as List).cast<String>(),
      );
      if (mounted) {
        _snack('Aggiornato');
        _load();
      }
    } catch (_) {
      if (mounted) {
        _snack('Errore modifica');
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina'),
        content: Text('Eliminare "${d['description']}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, false);
            },
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    try {
      await _svc.deleteDocument(d['id']);
      if (mounted) {
        _snack('Eliminato');
        _load();
      }
    } catch (_) {
      if (mounted) {
        _snack('Errore');
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

  Widget _buildCard(Map<String, dynamic> d) {
    final t = Theme.of(context);
    final enti =
        (d['enti'] as List?)
            ?.map((e) => e['ente']?['nome'] as String?)
            .where((n) => n != null)
            .cast<String>()
            .toList() ??
        [];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(d['description'] ?? '', style: t.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: enti
                  .map((n) => EnteBadge(nome: n, fontSize: 14))
                  .toList(),
            ),
            const SizedBox(height: 4),
            Text(
              'Data: ${_fmt(d['documentDate'] ?? '')}',
              style: t.textTheme.bodySmall,
            ),
            Text(
              'File: ${d['fileName'] ?? ''}',
              style: TextStyle(color: Colors.amber.shade200, fontSize: 13),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.cyanAccent),
              onPressed: () {
                _pdf.open(d);
              },
              tooltip: 'Anteprima',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.greenAccent),
              onPressed: () {
                _pdf.download(d);
              },
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                _edit(d);
              },
              tooltip: 'Modifica',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                _delete(d);
              },
              tooltip: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: DashboardAppBar(
        onUpload: _upload,
        service: _svc,
        searchController: TextEditingController(),
        onSearch: (v) {},
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WebDocumentsEnti(),
                      ),
                    );
                    if (mounted) {
                      _load();
                    }
                  },
                  icon: const Icon(Icons.business, size: 22),
                  label: const Text('Enti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
                    foregroundColor: const Color(0xFFF08A5D),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WebDocumentsUsers(),
                    ),
                  ),
                  icon: const Icon(Icons.people, size: 22),
                  label: const Text('Utenti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                    foregroundColor: const Color(0xFF4ECDC4),
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
                : _docs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: t.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text('Nessun documento', style: t.textTheme.bodyMedium),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _upload,
                          icon: const Icon(Icons.add),
                          label: const Text('Carica il primo documento'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _docs.length,
                    itemBuilder: (_, i) => _buildCard(_docs[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

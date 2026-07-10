import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/document_form_dialog.dart';
import 'package:webdocuments/screens/widgets/dashboard_app_bar.dart';

class WebDocumentsDashboard extends StatefulWidget {
  const WebDocumentsDashboard({super.key});
  @override
  State<WebDocumentsDashboard> createState() => _WebDocumentsDashboardState();
}

class _WebDocumentsDashboardState extends State<WebDocumentsDashboard> {
  final _svc = WebDocumentsService();
  final _pdf = PdfHelper(AuthStorage());
  List<dynamic> _docs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
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

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<Map<String, String>?> _form([Map<String, dynamic>? doc]) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => DocumentFormDialog(
        initialDescription: doc?['description'] ?? '',
        initialDate: doc?['documentDate'] ?? '',
        initialEnteId: doc?['enteId'] ?? doc?['ente']?['id'] ?? '',
      ),
    );
  }

  Future<void> _upload() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (r == null || r.files.isEmpty) {
      return;
    }
    final f = r.files.first;
    if (f.bytes == null || !mounted) {
      return;
    }
    final form = await _form();
    if (form == null) {
      return;
    }
    try {
      await _svc.createDocument(
        description: form['description']!,
        documentDate: form['documentDate']!,
        enteId: form['enteId']!,
        fileBytes: f.bytes!,
        fileName: f.name,
      );
      _snack('Caricato');
      _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
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
        enteId: form['enteId'],
      );
      _snack('Aggiornato');
      _load();
    } catch (_) {
      _snack('Errore modifica');
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
      _snack('Eliminato');
      _load();
    } catch (_) {
      _snack('Errore');
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
    final enteNome = d['ente']?['nome'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(d['description'] ?? '', style: t.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ente: $enteNome', style: t.textTheme.bodySmall),
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
    );
  }
}

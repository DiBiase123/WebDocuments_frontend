import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/pdf_helper.dart';
import 'package:webdocuments/screens/widgets/document_form_dialog.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_controller.dart';

class DashboardController extends ChangeNotifier {
  final _svc = WebDocumentsService();
  final _pdf = PdfHelper(AuthStorage());
  List<dynamic> docs = [];
  bool loading = true;
  String? error;
  String _searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  WebDocumentsService get svc => _svc;

  List<dynamic> get filteredDocs {
    if (_searchQuery.isEmpty) return docs;
    return docs
        .where(
          (d) => '${d['description'] ?? ''} ${d['fileName'] ?? ''}'
              .toLowerCase()
              .contains(_searchQuery),
        )
        .toList();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      docs = await _svc.getDocuments();
    } catch (_) {
      error = 'Errore nel caricamento';
    }
    loading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void openPdf(Map<String, dynamic> d) => _pdf.open(d);
  void downloadPdf(Map<String, dynamic> d) => _pdf.download(d);

  Future<Map<String, dynamic>?> form([Map<String, dynamic>? doc]) {
    List<String>? enteIds;
    if (doc?['enti'] != null) {
      enteIds = (doc!['enti'] as List)
          .map((e) => e['ente']?['id'] as String)
          .toList();
    } else if (doc?['enteId'] != null) {
      enteIds = [doc!['enteId'] as String];
    }
    final ctx = ExtractController.navigatorKey.currentContext;
    if (ctx == null) return Future.value(null);
    return showDialog<Map<String, dynamic>>(
      context: ctx,
      builder: (_) => DocumentFormDialog(
        initialDescription: doc?['description'],
        initialDate: doc?['documentDate'],
        initialEnteIds: enteIds,
      ),
    );
  }

  Future<void> upload() async {
    try {
      final f = await form();
      if (f == null) return;
      final file = f['file'] as PlatformFile?;
      if (file == null || file.bytes == null) return;
      await _svc.createDocument(
        description: f['description']!,
        documentDate: f['documentDate']!,
        enteIds: (f['enteIds'] as List).cast<String>(),
        fileBytes: file.bytes!,
        fileName: file.name,
      );
      snack('Caricato');
      await load();
    } catch (e) {
      dev.log('ERRORE UPLOAD: $e', name: 'DashboardController');
      snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> edit(Map<String, dynamic> d) async {
    final f = await form(d);
    if (f == null) return;
    try {
      await _svc.updateDocument(
        id: d['id'],
        description: f['description'],
        documentDate: f['documentDate'],
        enteIds: (f['enteIds'] as List).cast<String>(),
      );
      snack('Aggiornato');
      await load();
    } catch (_) {
      snack('Errore modifica');
    }
  }

  Future<void> delete(Map<String, dynamic> d) async {
    final ctx = ExtractController.navigatorKey.currentContext;
    if (ctx == null) return;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Elimina'),
        content: Text('Eliminare "${d['description']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _svc.deleteDocument(d['id']);
      snack('Eliminato');
      await load();
    } catch (_) {
      snack('Errore');
    }
  }

  void snack(String msg) {
    final ctx = ExtractController.navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

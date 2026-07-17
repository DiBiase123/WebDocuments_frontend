import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/document_form_dialog.dart';

class ExtractController extends ChangeNotifier {
  final _svc = WebDocumentsService();
  bool loading = false;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> uploadWithData({
    required String description,
    required String documentDate,
    required String enteNome,
    required List<int> bytes,
    required String fileName,
  }) async {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      dev.log('uploadWithData: context nullo', name: 'ExtractController');
      return;
    }
    try {
      loading = true;
      notifyListeners();

      String? enteId;
      try {
        final enti = await _svc.getEnti();
        if (!ctx.mounted) {
          loading = false;
          notifyListeners();
          return;
        }
        final existing = enti.firstWhere(
          (e) =>
              (e['nome'] ?? '').toString().toLowerCase() ==
              enteNome.toLowerCase(),
          orElse: () => null,
        );
        if (existing != null) {
          enteId = existing['id'];
          dev.log(
            'uploadWithData: ente trovato: $enteNome (id: $enteId)',
            name: 'ExtractController',
          );
        } else {
          final nuovo = await _svc.createEnte(enteNome);
          if (!ctx.mounted) {
            loading = false;
            notifyListeners();
            return;
          }
          enteId = nuovo['id'];
          dev.log(
            'uploadWithData: ente creato: $enteNome (id: $enteId)',
            name: 'ExtractController',
          );
        }
      } catch (e) {
        dev.log('uploadWithData: errore ente: $e', name: 'ExtractController');
      }

      if (!ctx.mounted) {
        loading = false;
        notifyListeners();
        return;
      }

      final formData = await showDialog<Map<String, dynamic>>(
        context: ctx,
        builder: (_) => DocumentFormDialog(
          initialDescription: description,
          initialDate: documentDate,
          initialEnteIds: enteId != null ? [enteId] : null,
          initialFileBytes: bytes,
          initialFileName: fileName,
        ),
      );
      if (formData == null) {
        loading = false;
        notifyListeners();
        return;
      }
      if (!ctx.mounted) {
        loading = false;
        notifyListeners();
        return;
      }
      final file = formData['file'] as PlatformFile?;
      await _svc.createDocument(
        description: formData['description']!,
        documentDate: formData['documentDate']!,
        enteIds: (formData['enteIds'] as List).cast<String>(),
        fileBytes: file?.bytes ?? bytes,
        fileName: file?.name ?? fileName,
      );
      snack('Caricato');
    } catch (e) {
      dev.log('ERRORE uploadWithData: $e', name: 'ExtractController');
      snack(e.toString().replaceFirst('Exception: ', ''));
    }
    loading = false;
    notifyListeners();
  }

  void snack(String msg) {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

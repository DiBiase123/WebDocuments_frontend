import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_document_form_body.dart';

class DocumentFormDialog extends StatefulWidget {
  final String? initialDescription, initialDate;
  final List<String>? initialEnteIds;
  final List<int>? initialFileBytes;
  final String? initialFileName;

  const DocumentFormDialog({
    super.key,
    this.initialDescription,
    this.initialDate,
    this.initialEnteIds,
    this.initialFileBytes,
    this.initialFileName,
  });

  @override
  State<DocumentFormDialog> createState() => _DocumentFormDialogState();
}

class _DocumentFormDialogState extends State<DocumentFormDialog> {
  final _svc = WebDocumentsService();
  final _key = GlobalKey<FormState>();
  late final _desc = TextEditingController(
    text: widget.initialDescription ?? '',
  );
  late final _date = TextEditingController(
    text: widget.initialDate?.isNotEmpty == true
        ? _fmt(widget.initialDate!)
        : '',
  );
  List<dynamic> _enti = [];
  List<String> _enteIds = [];
  PlatformFile? _file;

  bool get isEditing => widget.initialDescription?.isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    _enteIds = widget.initialEnteIds ?? [];
    if (widget.initialFileBytes != null && widget.initialFileName != null) {
      _file = PlatformFile(
        name: widget.initialFileName!,
        size: widget.initialFileBytes!.length,
        bytes: Uint8List.fromList(widget.initialFileBytes!),
      );
    }
    _loadEnti();
  }

  Future<void> _loadEnti() async {
    try {
      final e = await _svc.getEnti();
      if (mounted) {
        setState(() => _enti = e);
      }
    } catch (_) {}
  }

  static String _fmt(String s) {
    try {
      final d = DateTime.parse(s);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return s;
    }
  }

  static String _apiDate(String s) {
    try {
      final p = s.split('/');
      return '${p[2]}-${p[1]}-${p[0]}';
    } catch (_) {
      return s;
    }
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (p != null) {
      setState(
        () => _date.text =
            '${p.day.toString().padLeft(2, '0')}/${p.month.toString().padLeft(2, '0')}/${p.year}',
      );
    }
  }

  void _onDateChanged(String v) {
    final c = v.replaceAll('/', '').length > 8
        ? v.replaceAll('/', '').substring(0, 8)
        : v.replaceAll('/', '');
    String f = '';
    for (int i = 0; i < c.length; i++) {
      if (i == 2 || i == 4) {
        f += '/';
      }
      f += c[i];
    }
    _date.value = TextEditingValue(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (r != null && r.files.isNotEmpty) {
      setState(() => _file = r.files.first);
    }
  }

  Future<void> _addEnte() async {
    final n = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          title: const Text('Nuovo ente'),
          content: TextField(
            controller: c,
            decoration: const InputDecoration(labelText: 'Nome ente'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Crea'),
            ),
          ],
        );
      },
    );
    if (n != null && n.isNotEmpty) {
      try {
        final ne = await _svc.createEnte(n);
        setState(() {
          _enti.add(ne);
          _enteIds.add(ne['id']);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    }
  }

  void _submit() {
    if (!isEditing && _file == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleziona un file PDF')));
      return;
    }
    if (_key.currentState!.validate()) {
      Navigator.pop(context, {
        'description': _desc.text.trim(),
        'documentDate': _apiDate(_date.text.trim()),
        'enteIds': _enteIds,
        if (_file != null) 'file': _file,
      });
    }
  }

  @override
  void dispose() {
    _desc.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica documento' : 'Inserisci documento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(isEditing ? 'Salva' : 'Crea'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: DocumentFormBody(
            descCtl: _desc,
            dateCtl: _date,
            enti: _enti,
            enteIds: _enteIds,
            file: _file,
            isEditing: isEditing,
            theme: Theme.of(context),
            onPickFile: _pickFile,
            onPickDate: _pickDate,
            onDateChanged: _onDateChanged,
            onAddEnte: _addEnte,
            onEnteToggle: (id, sel) =>
                setState(() => sel ? _enteIds.add(id) : _enteIds.remove(id)),
          ),
        ),
      ),
    );
  }
}

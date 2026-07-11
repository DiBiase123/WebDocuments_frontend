import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class DocumentFormDialog extends StatefulWidget {
  final String? initialDescription, initialDate;
  final List<String>? initialEnteIds;
  const DocumentFormDialog({
    super.key,
    this.initialDescription,
    this.initialDate,
    this.initialEnteIds,
  });
  @override
  State<DocumentFormDialog> createState() => _DocumentFormDialogState();
}

class _DocumentFormDialogState extends State<DocumentFormDialog> {
  final _svc = WebDocumentsService();
  late final _desc = TextEditingController(
    text: widget.initialDescription ?? '',
  );
  late final _date = TextEditingController(
    text: widget.initialDate?.isNotEmpty == true
        ? _fmt(widget.initialDate!)
        : '',
  );
  final _key = GlobalKey<FormState>();
  List<dynamic> _enti = [];
  List<String> _enteIds = [];
  PlatformFile? _file;

  bool get isEditing =>
      widget.initialDescription != null &&
      widget.initialDescription!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _enteIds = widget.initialEnteIds ?? [];
    _loadEnti();
  }

  Future<void> _loadEnti() async {
    try {
      final enti = await _svc.getEnti();
      if (mounted) {
        setState(() {
          _enti = enti;
        });
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('it'),
    );
    if (picked != null) {
      setState(() {
        _date.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onDateChanged(String value) {
    String cleaned = value.replaceAll('/', '');
    if (cleaned.length > 8) cleaned = cleaned.substring(0, 8);
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += cleaned[i];
    }
    _date.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<void> _addEnte() async {
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nuovo ente'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Nome ente'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Crea'),
            ),
          ],
        );
      },
    );
    if (nome != null && nome.isNotEmpty) {
      try {
        final newEnte = await _svc.createEnte(nome);
        setState(() {
          _enti.add(newEnte);
          _enteIds.add(newEnte['id']);
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

  @override
  void dispose() {
    _desc.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica documento' : 'Inserisci documento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                if (!isEditing && _file == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleziona un file PDF')),
                  );
                  return;
                }
                if (_enteIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleziona almeno un ente')),
                  );
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
              },
              child: Text(isEditing ? 'Salva' : 'Crea'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isEditing) ...[
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file, size: 28),
                  label: Text(
                    _file != null ? _file!.name : 'Seleziona file PDF',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: t.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _desc,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  labelStyle: const TextStyle(fontSize: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty != false ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _date,
                onChanged: _onDateChanged,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Data (GG/MM/AAAA)',
                  hintText: '08/07/2026',
                  labelStyle: const TextStyle(fontSize: 18),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 60,
                    minHeight: 44,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.calendar_month, size: 36),
                      onPressed: _pickDate,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v?.trim().isEmpty != false ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enti',
                          style: TextStyle(
                            fontSize: 16,
                            color: t.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _enti.map((e) {
                            final id = e['id'] as String;
                            final selected = _enteIds.contains(id);
                            return FilterChip(
                              label: Text(
                                e['nome'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selected ? Colors.white : null,
                                ),
                              ),
                              selected: selected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _enteIds.add(id);
                                  } else {
                                    _enteIds.remove(id);
                                  }
                                });
                              },
                              selectedColor: t.colorScheme.primary.withAlpha(
                                100,
                              ),
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFFF08A5D),
                      size: 36,
                    ),
                    onPressed: _addEnte,
                    tooltip: 'Nuovo ente',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

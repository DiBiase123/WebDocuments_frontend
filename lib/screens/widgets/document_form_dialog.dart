import 'package:flutter/material.dart';

class DocumentFormDialog extends StatefulWidget {
  final String? initialDescription, initialDate, initialEnte;
  const DocumentFormDialog({
    super.key,
    this.initialDescription,
    this.initialDate,
    this.initialEnte,
  });
  @override
  State<DocumentFormDialog> createState() => _DocumentFormDialogState();
}

class _DocumentFormDialogState extends State<DocumentFormDialog> {
  late final _desc = TextEditingController(
    text: widget.initialDescription ?? '',
  );
  late final _date = TextEditingController(
    text: widget.initialDate?.isNotEmpty == true
        ? _fmt(widget.initialDate!)
        : '',
  );
  late final _ente = TextEditingController(text: widget.initialEnte ?? '');
  final _key = GlobalKey<FormState>();

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

  @override
  void dispose() {
    _desc.dispose();
    _date.dispose();
    _ente.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.initialDescription != null;
    return AlertDialog(
      title: Text(edit ? 'Modifica' : 'Nuovo documento'),
      content: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              validator: (v) =>
                  v?.trim().isEmpty != false ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _date,
              decoration: const InputDecoration(
                labelText: 'Data (GG/MM/AAAA)',
                hintText: '10/07/2026',
              ),
              validator: (v) =>
                  v?.trim().isEmpty != false ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ente,
              decoration: const InputDecoration(labelText: 'Ente'),
              validator: (v) =>
                  v?.trim().isEmpty != false ? 'Obbligatorio' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              Navigator.pop(context, {
                'description': _desc.text.trim(),
                'documentDate': _apiDate(_date.text.trim()),
                'ente': _ente.text.trim(),
              });
            }
          },
          child: Text(edit ? 'Salva' : 'Carica'),
        ),
      ],
    );
  }
}

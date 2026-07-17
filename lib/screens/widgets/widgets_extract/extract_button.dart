import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_service.dart';

class ExtractButton extends StatefulWidget {
  final void Function(String text) onTextExtracted;

  const ExtractButton({super.key, required this.onTextExtracted});

  @override
  State<ExtractButton> createState() => _ExtractButtonState();
}

class _ExtractButtonState extends State<ExtractButton> {
  final _service = ExtractService();
  bool _loading = false;

  Future<void> _extract() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() => _loading = true);
    try {
      final text = await _service.extractText(file.bytes!, file.name);
      widget.onTextExtracted(text);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _extract,
      icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.document_scanner),
      label: Text(_loading ? 'Estrazione...' : 'Estrai testo da PDF'),
    );
  }
}

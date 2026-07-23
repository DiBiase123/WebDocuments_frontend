import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_service.dart';
import 'package:webdocuments/services/webdocuments_ai.dart';

typedef ExtractedDataCallback =
    void Function(Map<String, String> data, List<int> bytes, String fileName);

class ExtractAiButton extends StatefulWidget {
  final ExtractedDataCallback onDataExtracted;

  const ExtractAiButton({super.key, required this.onDataExtracted});

  @override
  State<ExtractAiButton> createState() => _ExtractAiButtonState();
}

class _ExtractAiButtonState extends State<ExtractAiButton> {
  final _extractService = ExtractService();
  final _aiService = AiService();
  bool _loading = false;
  String _status = '';

  Future<void> _process() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.first;
    if (file.bytes == null) {
      return;
    }

    setState(() {
      _loading = true;
      _status = 'Estrazione testo...';
    });

    try {
      final text = await _extractService.extractText(file.bytes!, file.name);
      setState(() => _status = 'Analisi AI...');
      final data = await _aiService.analyzeText(text);
      widget.onDataExtracted(data, file.bytes!, file.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    setState(() {
      _loading = false;
      _status = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _process,
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_awesome),
      label: Text(_loading ? _status : 'Estrai e Analizza con AI'),
    );
  }
}

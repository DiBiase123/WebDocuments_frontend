import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_button.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_ai_button.dart';

class DashboardExtractFab extends StatelessWidget {
  final Function(String) onTextExtracted;
  final Function(Map<String, String>, List<int>, String) onDataExtracted;

  const DashboardExtractFab({
    super.key,
    required this.onTextExtracted,
    required this.onDataExtracted,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Estrai testo da PDF',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ExtractButton(
                  onTextExtracted: (text) {
                    Navigator.pop(ctx);
                    onTextExtracted(text);
                  },
                ),
                const SizedBox(height: 12),
                const Text('oppure', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 12),
                ExtractAiButton(
                  onDataExtracted: (data, bytes, fileName) {
                    Navigator.pop(ctx);
                    onDataExtracted(data, bytes, fileName);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      icon: const Icon(Icons.document_scanner),
      label: const Text('Estrai PDF'),
    );
  }
}

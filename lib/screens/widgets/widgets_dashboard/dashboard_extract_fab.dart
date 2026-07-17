import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_extract/extract_ai_button.dart';

class DashboardExtractFab extends StatelessWidget {
  final Function(Map<String, String>, List<int>, String) onDataExtracted;

  const DashboardExtractFab({super.key, required this.onDataExtracted});

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
                  'Estrai e Analizza con AI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Estrai PDF'),
    );
  }
}

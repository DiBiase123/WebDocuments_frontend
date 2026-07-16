import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_desktop_button.dart';

class EntiHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onAdd;

  const EntiHeader({super.key, required this.isMobile, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Row(
        children: [
          Text(
            'Gestione Enti :',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (!isMobile) ...[const Spacer(), EntiDesktopButton(onAdd: onAdd)],
        ],
      ),
    );
  }
}

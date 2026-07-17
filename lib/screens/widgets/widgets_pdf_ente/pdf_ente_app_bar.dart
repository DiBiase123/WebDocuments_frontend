import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_controller.dart';

class PdfEnteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PdfEnteController ctrl;
  final bool isMobile;

  const PdfEnteAppBar({super.key, required this.ctrl, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (!isMobile) ...[
            const Text('WebDocuments'),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: ctrl.searchCtl,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Cerca ente...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Indietro',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () => ctrl.logout(context),
            tooltip: 'Logout',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

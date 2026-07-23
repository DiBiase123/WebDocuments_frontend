import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_logout_button.dart';

class UsersAppBar extends StatelessWidget implements PreferredSizeWidget {
  final WebDocumentsService service;
  final bool isWide;

  const UsersAppBar({super.key, required this.service, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (isWide) ...[
            const Text('WebDocuments'),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Cerca utente...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 24,
                  ),
                  filled: true,
                  fillColor: Colors.white.withAlpha(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
          child: LogoutButton(service: service),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

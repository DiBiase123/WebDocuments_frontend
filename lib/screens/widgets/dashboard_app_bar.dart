import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_enti.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUpload;
  final VoidCallback onEntiChanged;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const DashboardAppBar({
    super.key,
    required this.onUpload,
    required this.onEntiChanged,
    required this.service,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Text('WebDocuments'),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Cerca...',
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
          icon: const Icon(Icons.business, color: Color(0xFFF08A5D)),
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WebDocumentsEnti()));
            onEntiChanged();
          },
          tooltip: 'Enti',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onUpload,
          tooltip: 'Carica',
        ),
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WebDocumentsList()),
            );
          },
          tooltip: 'Lista',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () async {
              await service.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
                );
              }
            },
            tooltip: 'Esci',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

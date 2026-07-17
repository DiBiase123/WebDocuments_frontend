import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/logout_button.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUpload;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final bool isMobile;

  const DashboardAppBar({
    super.key,
    required this.onUpload,
    required this.service,
    required this.searchController,
    required this.onSearch,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (!isMobile) ...[
            const Text('WebDocuments'),
            const SizedBox(width: 16),
          ],
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
        if (!isMobile) ...[
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
        ],
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

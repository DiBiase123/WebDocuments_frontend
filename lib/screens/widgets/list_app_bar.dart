import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearch;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final bool isAdmin;

  const ListAppBar({
    super.key,
    this.onSearch,
    required this.service,
    required this.searchController,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SizedBox(
        height: 44,
        child: TextField(
          controller: searchController,
          onChanged: onSearch,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Cerca...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 18),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white54,
              size: 28,
            ),
            filled: true,
            fillColor: Colors.white.withAlpha(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const WebDocumentsDashboard(),
                ),
              );
            },
            tooltip: 'Dashboard',
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
  Size get preferredSize => const Size.fromHeight(80);
}

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_logout_button.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearch;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final bool isAdmin;
  final bool isMobile;
  final VoidCallback onDashboard;
  final VoidCallback onEnte;
  final VoidCallback onDate;

  const ListAppBar({
    super.key,
    this.onSearch,
    required this.service,
    required this.searchController,
    required this.isAdmin,
    required this.isMobile,
    required this.onDashboard,
    required this.onEnte,
    required this.onDate,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Cerca...',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 24),
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
      actions: [
        if (!isMobile && isAdmin)
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: onDashboard,
            tooltip: 'Dashboard',
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

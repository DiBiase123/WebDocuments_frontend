import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_logout_button.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class ListAppBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final WebDocumentsService service;

  const ListAppBarMobile({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.service,
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

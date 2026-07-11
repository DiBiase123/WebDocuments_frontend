import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearch;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final bool isAdmin;
  final VoidCallback? onEnte;
  final VoidCallback? onData;

  const ListAppBar({
    super.key,
    this.onSearch,
    required this.service,
    required this.searchController,
    required this.isAdmin,
    this.onEnte,
    this.onData,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SizedBox(
        height: 40,
        child: TextField(
          controller: searchController,
          onChanged: onSearch,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Cerca...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
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
  Size get preferredSize => const Size.fromHeight(70);
}

class ListSliverAppBar extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final WebDocumentsService service;
  final TextEditingController searchController;
  final bool isAdmin;
  final VoidCallback? onEnte;
  final VoidCallback? onData;

  const ListSliverAppBar({
    super.key,
    this.onSearch,
    required this.service,
    required this.searchController,
    required this.isAdmin,
    this.onEnte,
    this.onData,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      snap: false,
      centerTitle: true,
      title: SizedBox(
        height: 40,
        child: TextField(
          controller: searchController,
          onChanged: onSearch,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Cerca...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.business, size: 18),
                label: const Text('Enti', style: TextStyle(fontSize: 14)),
                onPressed: onEnte,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
                  foregroundColor: const Color(0xFFF08A5D),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('Date', style: TextStyle(fontSize: 14)),
                onPressed: onData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4).withAlpha(30),
                  foregroundColor: const Color(0xFF4ECDC4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

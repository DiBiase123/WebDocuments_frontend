import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/services/webdocuments_service.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUpload;
  final WebDocumentsService service;

  const DashboardAppBar({
    super.key,
    required this.onUpload,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.list),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WebDocumentsList()),
          );
        },
        tooltip: 'Lista',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onUpload,
          tooltip: 'Carica',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

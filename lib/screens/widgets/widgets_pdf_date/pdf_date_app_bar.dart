import 'package:flutter/material.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class PdfDateAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PdfDateAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title),
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
            onPressed: () async {
              await AuthStorage().clearAuthData();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
              );
            },
            tooltip: 'Logout',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

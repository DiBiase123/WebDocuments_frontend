import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class LogoutButton extends StatelessWidget {
  final WebDocumentsService service;
  const LogoutButton({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
    );
  }
}

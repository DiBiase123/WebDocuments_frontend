import 'package:flutter/material.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class RegisterSuccessDialog extends StatelessWidget {
  final String email;

  const RegisterSuccessDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrazione completata!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.mark_email_unread,
            size: 70,
            color: Color(0xFFF08A5D),
          ),
          const SizedBox(height: 20),
          const Text(
            'Abbiamo inviato un\'email di verifica a:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF08A5D).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(email, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          const Text(
            'Clicca sul link ricevuto per attivare il tuo account.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
            );
          },
          child: const Text('HO CAPITO'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class EntiCard extends StatelessWidget {
  final dynamic ente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EntiCard({
    super.key,
    required this.ente,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: EnteBadge(nome: ente['nome'] ?? '', fontSize: 18),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: onEdit,
              tooltip: 'Modifica',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
              tooltip: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }
}

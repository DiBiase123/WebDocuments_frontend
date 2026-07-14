import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_card.dart';

class EntiList extends StatelessWidget {
  final List<dynamic> enti;
  final bool loading;
  final void Function(String id, String nome) onEdit;
  final void Function(String id) onDelete;

  const EntiList({
    super.key,
    required this.enti,
    required this.loading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (enti.isEmpty) {
      return Center(child: Text('Nessun ente', style: t.textTheme.bodyMedium));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: enti.length,
      itemBuilder: (_, i) {
        final e = enti[i];
        return EntiCard(
          ente: e,
          onEdit: () => onEdit(e['id'], e['nome']),
          onDelete: () => onDelete(e['id']),
        );
      },
    );
  }
}

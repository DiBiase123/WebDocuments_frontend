import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/ente_badge.dart';

class WebDocumentsEnti extends StatefulWidget {
  const WebDocumentsEnti({super.key});
  @override
  State<WebDocumentsEnti> createState() => _WebDocumentsEntiState();
}

class _WebDocumentsEntiState extends State<WebDocumentsEnti> {
  final _svc = WebDocumentsService();
  List<dynamic> _enti = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final enti = await _svc.getEnti();
      if (mounted) {
        setState(() {
          _enti = enti;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _add() async {
    final nome = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Nuovo ente'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Nome ente'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Crea'),
            ),
          ],
        );
      },
    );
    if (nome != null && nome.isNotEmpty) {
      try {
        await _svc.createEnte(nome);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    }
  }

  Future<void> _edit(String id, String nome) async {
    final newNome = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: nome);
        return AlertDialog(
          title: const Text('Modifica ente'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Nome ente'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
    if (newNome != null && newNome.isNotEmpty) {
      try {
        await _svc.updateEnte(id, newNome);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      }
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _svc.deleteEnte(id);
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Impossibile eliminare')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione enti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _add,
            tooltip: 'Nuovo ente',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _enti.isEmpty
          ? Center(child: Text('Nessun ente', style: t.textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _enti.length,
              itemBuilder: (_, i) {
                final e = _enti[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: EnteBadge(nome: e['nome'] ?? '', fontSize: 18),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _edit(e['id'], e['nome']);
                          },
                          tooltip: 'Modifica',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            _delete(e['id']);
                          },
                          tooltip: 'Elimina',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

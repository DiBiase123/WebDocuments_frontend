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
  final _searchCtl = TextEditingController();
  List<dynamic> _enti = [], _filtered = [];
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
          _filtered = enti;
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

  void _onSearch(String q) {
    final f = q.toLowerCase();
    setState(
      () => _filtered = f.isEmpty
          ? _enti
          : _enti
                .where(
                  (e) => (e['nome'] ?? '').toString().toLowerCase().contains(f),
                )
                .toList(),
    );
  }

  Future<String?> _showEnteDialog({
    String? initialValue,
    bool isEdit = false,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: initialValue ?? '');
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isEdit ? 'Modifica ente' : 'Nuovo ente',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: 'Nome ente',
                labelStyle: const TextStyle(fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(ctx).colorScheme.surface.withAlpha(100),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx, ctrl.text.trim());
              },
              child: Text(
                isEdit ? 'Salva' : 'Crea',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _add() async {
    final nome = await _showEnteDialog();
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
    final newNome = await _showEnteDialog(initialValue: nome, isEdit: true);
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
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('WebDocuments'),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchCtl,
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Cerca ente...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
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
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _add,
              tooltip: 'Nuovo ente',
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
          ? Center(child: Text('Nessun ente', style: t.textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final e = _filtered[i];
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
      bottomNavigationBar: isMobile
          ? Container(
              width: double.infinity,
              height: 50,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white12),
                          ),
                        ),
                        child: InkWell(
                          splashColor: const Color(0xFFF08A5D).withAlpha(60),
                          highlightColor: const Color(0xFFF08A5D).withAlpha(30),
                          onTap: _add,
                          child: const Center(
                            child: Icon(Icons.add, color: Color(0xFFF08A5D)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

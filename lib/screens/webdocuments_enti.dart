import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/services/webdocuments_auth_guard.dart';
import 'package:webdocuments/screens/widgets/widgets_common/common_animated_app_bar.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_mobile.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_list.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_footer.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_dialog.dart';

class WebDocumentsEnti extends StatefulWidget {
  const WebDocumentsEnti({super.key});
  @override
  State<WebDocumentsEnti> createState() => _WebDocumentsEntiState();
}

class _WebDocumentsEntiState extends State<WebDocumentsEnti> {
  final _svc = WebDocumentsService();
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  List<dynamic> _enti = [], _filtered = [];
  bool _loading = true, _showAppBar = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtl.addListener(() {
      final o = _scrollCtl.offset;
      if (o <= 0) {
        if (!_showAppBar) {
          setState(() => _showAppBar = true);
        }
      } else if ((o > _lastOffset && o > 70 && _showAppBar) ||
          (o < _lastOffset && !_showAppBar)) {
        setState(() => _showAppBar = !_showAppBar);
      }
      _lastOffset = o;
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
        setState(() => _loading = false);
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

  Future<void> _add() async {
    final nome = await showEnteDialog(context);
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
    final newNome = await showEnteDialog(
      context,
      initialValue: nome,
      isEdit: true,
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
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina ente'),
        content: const Text('Sei sicuro di voler eliminare questo ente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (conferma != true) {
      return;
    }
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
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return AuthGuard(
      allowedRoles: ['ADMIN', 'SUPER_ADMIN'],
      child: Scaffold(
        appBar: AnimatedAppBar(
          visible: _showAppBar,
          child: isMobile
              ? EntiAppBarMobile(
                  searchController: _searchCtl,
                  onSearch: _onSearch,
                  service: _svc,
                )
              : EntiAppBarDesktop(
                  searchController: _searchCtl,
                  onSearch: _onSearch,
                  onBack: () => Navigator.pop(context),
                  service: _svc,
                ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(32, 16, 32, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Gestione Enti :',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isMobile)
                    ElevatedButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.add, size: 32),
                      label: const Text(
                        'Crea ente',
                        style: TextStyle(fontSize: 22),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF08A5D).withAlpha(30),
                        foregroundColor: const Color(0xFFF08A5D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: EntiList(
                enti: _filtered,
                loading: _loading,
                onEdit: _edit,
                onDelete: _delete,
                scrollController: _scrollCtl,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isMobile
            ? EntiFooter(onBack: () => Navigator.pop(context), onAdd: _add)
            : null,
      ),
    );
  }
}

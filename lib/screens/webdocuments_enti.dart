import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';
import 'package:webdocuments/screens/webdocuments_list.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_mobile.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_desktop_button.dart';
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
  final _auth = AuthStorage();
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  List<dynamic> _enti = [], _filtered = [];
  bool _loading = true, _showAppBar = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final auth = await _auth.loadAuthData();
    if (auth == null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
      return;
    }
    if (auth!['role'] != 'ADMIN' && auth['role'] != 'SUPER_ADMIN') {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WebDocumentsList()),
        );
      }
      return;
    }
    _load();
    _scrollCtl.addListener(() {
      final o = _scrollCtl.offset;
      if (o <= 0) {
        if (!_showAppBar) setState(() => _showAppBar = true);
      } else if ((o > _lastOffset && o > 70 && _showAppBar) ||
          (o < _lastOffset && !_showAppBar)) {
        setState(() => _showAppBar = !_showAppBar);
      }
      _lastOffset = o;
    });
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showAppBar ? 70 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showAppBar ? 70 : 0,
          child: _showAppBar
              ? isMobile
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
                      )
              : const SizedBox.shrink(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
            child: Row(
              children: [
                Text(
                  'Gestione Enti :',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!isMobile) ...[
                  const Spacer(),
                  EntiDesktopButton(onAdd: _add),
                ],
              ],
            ),
          ),
          Expanded(
            child: EntiList(
              enti: _filtered,
              loading: false,
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
    );
  }
}

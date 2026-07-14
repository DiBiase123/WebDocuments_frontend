import 'package:flutter/material.dart';
import 'package:webdocuments/services/webdocuments_service.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_dialog.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_app_bar_mobile.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_desktop_button.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_list.dart';
import 'package:webdocuments/screens/widgets/widgets_enti/enti_footer.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
          if (!isMobile) EntiDesktopButton(onAdd: _add),
          Expanded(
            child: EntiList(
              enti: _filtered,
              loading: _loading,
              onEdit: _edit,
              onDelete: _delete,
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

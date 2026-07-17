import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';
import 'package:webdocuments/screens/webdocuments_login.dart';

class PdfEnteController extends ChangeNotifier {
  final _auth = AuthStorage();
  final List<dynamic> docs;
  final TextEditingController searchCtl = TextEditingController();
  bool ascending = true;
  String searchQuery = '';

  PdfEnteController(this.docs) {
    searchCtl.addListener(() {
      searchQuery = searchCtl.text.toLowerCase();
      notifyListeners();
    });
  }

  Map<String, List<dynamic>> get grouped {
    final Map<String, List<dynamic>> map = {};
    for (final d in docs) {
      final enti =
          (d['enti'] as List?)
              ?.map((e) => e['ente']?['nome'] as String?)
              .where((n) => n != null)
              .cast<String>()
              .toList() ??
          ['Senza ente'];
      for (final nome in enti) {
        if (searchQuery.isNotEmpty &&
            !nome.toLowerCase().contains(searchQuery)) {
          continue;
        }
        map.putIfAbsent(nome, () => []).add(d);
      }
    }
    return map;
  }

  List<String> get sortedKeys {
    final keys = grouped.keys.toList()..sort();
    if (!ascending) {
      keys.sort((a, b) => b.compareTo(a));
    }
    return keys;
  }

  void toggleAscending() {
    ascending = !ascending;
    notifyListeners();
  }

  Future<void> openPdf(Map<String, dynamic> d) async {
    final auth = await _auth.loadAuthData();
    final uri = Uri.parse(
      '${Config.buildUrl()}/api/webdocuments/${d['id']}/download?token=${auth?['token'] ?? ''}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> downloadPdf(Map<String, dynamic> d) async {
    final auth = await _auth.loadAuthData();
    final url =
        '${Config.buildUrl()}/api/webdocuments/${d['id']}/download?token=${auth?['token'] ?? ''}&download=true';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', d['fileName'] ?? 'document.pdf')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }

  Future<void> logout(BuildContext context) async {
    await _auth.clearAuthData();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WebDocumentsLogin()),
      );
    }
  }

  @override
  void dispose() {
    searchCtl.dispose();
    super.dispose();
  }
}

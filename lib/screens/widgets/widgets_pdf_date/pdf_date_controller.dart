import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';

class PdfDateController extends ChangeNotifier {
  final _auth = AuthStorage();
  final List<dynamic> docs;
  late List<dynamic> _sorted;
  late Map<String, List<dynamic>> _grouped;
  bool ascending = false;
  bool sortByEnte = false;

  PdfDateController(this.docs) {
    _sort();
  }

  Map<String, List<dynamic>> get grouped => _grouped;

  void _sort() {
    _sorted = List.from(docs);
    if (sortByEnte) {
      _sorted.sort((a, b) {
        final ea =
            (a['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] ?? '')
                .join(',') ??
            '';
        final eb =
            (b['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] ?? '')
                .join(',') ??
            '';
        return ascending ? ea.compareTo(eb) : eb.compareTo(ea);
      });
      _grouped = {};
      for (final d in _sorted) {
        final enti =
            (d['enti'] as List?)
                ?.map((e) => e['ente']?['nome'] as String?)
                .where((n) => n != null)
                .cast<String>()
                .join(', ') ??
            'Senza ente';
        _grouped.putIfAbsent(enti, () => []).add(d);
      }
    } else {
      _sorted.sort((a, b) {
        final da = a['documentDate'] ?? '';
        final db = b['documentDate'] ?? '';
        return ascending ? da.compareTo(db) : db.compareTo(da);
      });
      _grouped = {};
      for (final d in _sorted) {
        final date = d['documentDate'] ?? '';
        final month = date.length >= 7 ? date.substring(0, 7) : 'Sconosciuto';
        _grouped.putIfAbsent(month, () => []).add(d);
      }
    }
    notifyListeners();
  }

  void toggleAscending() {
    ascending = !ascending;
    _sort();
  }

  void toggleSortByEnte() {
    sortByEnte = !sortByEnte;
    _sort();
  }

  String monthName(String yyyymm) {
    try {
      final parts = yyyymm.split('-');
      if (parts.length != 2) return yyyymm;
      final m = int.parse(parts[1]), y = parts[0];
      const months = [
        '',
        'Gen',
        'Feb',
        'Mar',
        'Apr',
        'Mag',
        'Giu',
        'Lug',
        'Ago',
        'Set',
        'Ott',
        'Nov',
        'Dic',
      ];
      return '${months[m]} $y';
    } catch (_) {
      return yyyymm;
    }
  }

  Future<void> openPdf(Map<String, dynamic> d) async {
    final auth = await _auth.loadAuthData();
    final url =
        '${Config.buildUrl()}/api/webdocuments/${d['id']}/download?token=${auth?['token'] ?? ''}';
    final uri = Uri.parse(url);
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

  List<String> sortedKeys() {
    final keys = _grouped.keys.toList();
    if (!ascending) {
      keys.sort((a, b) => b.compareTo(a));
    } else {
      keys.sort();
    }
    return keys;
  }
}

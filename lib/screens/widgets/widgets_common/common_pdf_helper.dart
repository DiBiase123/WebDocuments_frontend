import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/webdocuments_auth_storage.dart';

class PdfHelper {
  final AuthStorage _authStorage;

  PdfHelper(this._authStorage);

  Future<String> getUrl(
    Map<String, dynamic> doc, {
    bool download = false,
  }) async {
    final auth = await _authStorage.loadAuthData();
    final base = Config.buildUrl();
    final url =
        '$base/api/webdocuments/${doc['id']}/download?token=${auth?['token'] ?? ''}';
    return download ? '$url&download=true' : url;
  }

  Future<void> open(Map<String, dynamic> doc) async {
    final uri = Uri.parse(await getUrl(doc));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  void download(Map<String, dynamic> doc) async {
    final anchor = html.AnchorElement(href: await getUrl(doc, download: true))
      ..setAttribute('download', doc['fileName'] ?? 'document.pdf')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
}

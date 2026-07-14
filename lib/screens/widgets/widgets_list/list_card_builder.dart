import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/document_card_mobile.dart';
import 'package:webdocuments/screens/widgets/document_card_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_helpers.dart';

class ListCardBuilder {
  final void Function(Map<String, dynamic>) onPreview;
  final void Function(Map<String, dynamic>) onDownload;

  ListCardBuilder({required this.onPreview, required this.onDownload});

  Widget build(dynamic d, bool isMobile) {
    final en = ListHelpers.entiNomi(d);
    final card = isMobile
        ? DocumentCardMobile(
            doc: d,
            formattedDate: ListHelpers.fmt(d['documentDate'] ?? ''),
            entiNomi: en,
            onPreview: () => onPreview(d),
            onDownload: () => onDownload(d),
          )
        : DocumentCardDesktop(
            doc: d,
            formattedDate: ListHelpers.fmt(d['documentDate'] ?? ''),
            entiNomi: en,
            onPreview: () => onPreview(d),
            onDownload: () => onDownload(d),
          );
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
  }
}

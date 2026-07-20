import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_card_desktop.dart';
import 'package:webdocuments/screens/widgets/widgets_dashboard/dashboard_card_mobile.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_helpers.dart';

class DashboardDocumentCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final bool isMobile;
  final void Function(Map<String, dynamic>) onPreview;
  final void Function(Map<String, dynamic>) onDownload;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;

  const DashboardDocumentCard({
    super.key,
    required this.doc,
    required this.isMobile,
    required this.onPreview,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final en = ListHelpers.entiNomi(doc);
    final card = isMobile
        ? DashboardCardMobile(
            doc: doc,
            formattedDate: ListHelpers.fmt(doc['documentDate'] ?? ''),
            entiNomi: en,
            onPreview: () => onPreview(doc),
            onDownload: () => onDownload(doc),
            onEdit: () => onEdit(doc),
            onDelete: () => onDelete(doc),
          )
        : DashboardCardDesktop(
            doc: doc,
            formattedDate: ListHelpers.fmt(doc['documentDate'] ?? ''),
            entiNomi: en,
            onPreview: () => onPreview(doc),
            onDownload: () => onDownload(doc),
            onEdit: () => onEdit(doc),
            onDelete: () => onDelete(doc),
          );
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
  }
}

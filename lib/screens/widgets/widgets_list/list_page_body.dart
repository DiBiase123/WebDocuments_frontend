import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_desktop_buttons.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_grouped_view.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_card_builder.dart';

class ListPageBody extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<dynamic> documents;
  final bool isMobile;
  final bool showAppBar;
  final bool ascending;
  final ListCardBuilder cardBuilder;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final VoidCallback onToggleOrder;
  final List<dynamic> docs;

  const ListPageBody({
    super.key,
    required this.loading,
    this.error,
    required this.documents,
    required this.isMobile,
    required this.showAppBar,
    required this.ascending,
    required this.cardBuilder,
    required this.scrollController,
    required this.onRetry,
    required this.onToggleOrder,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isMobile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: showAppBar ? 80 : 0,
            color: Colors.transparent,
            child: ClipRect(
              child: ListDesktopButtons(
                docs: docs,
                ascending: ascending,
                onToggleOrder: onToggleOrder,
              ),
            ),
          ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onRetry,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : documents.isEmpty
              ? const Center(
                  child: Text(
                    'Nessun documento',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListGroupedView(
                  documents: documents,
                  isMobile: isMobile,
                  ascending: ascending,
                  cardBuilder: cardBuilder,
                  scrollController: scrollController,
                ),
        ),
      ],
    );
  }
}

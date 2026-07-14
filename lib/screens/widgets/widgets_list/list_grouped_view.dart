import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/month_section.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_helpers.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_card_builder.dart';

class ListGroupedView extends StatelessWidget {
  final List<dynamic> documents;
  final bool isMobile;
  final bool ascending;
  final ListCardBuilder cardBuilder;
  final ScrollController scrollController;

  const ListGroupedView({
    super.key,
    required this.documents,
    required this.isMobile,
    required this.ascending,
    required this.cardBuilder,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<dynamic>>{};
    for (final d in documents) {
      grouped
          .putIfAbsent(
            ListHelpers.monthLabel(d['documentDate'] ?? ''),
            () => [],
          )
          .add(d);
    }
    final months = grouped.keys.toList()
      ..sort((a, b) => ascending ? a.compareTo(b) : b.compareTo(a));
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: months.length,
      itemBuilder: (_, i) {
        final m = months[i];
        final cards = grouped[m]!
            .map((d) => cardBuilder.build(d, isMobile))
            .toList();
        return MonthSection(
          month: m,
          docCount: cards.length,
          cards: cards,
          sectionKey: GlobalKey(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_desktop_buttons.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_grouped_view.dart';
import 'package:webdocuments/screens/widgets/widgets_list/list_card_builder.dart';

class ListPageBody extends StatefulWidget {
  final bool loading;
  final String? error;
  final List<dynamic> documents;
  final bool isMobile;
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
    required this.ascending,
    required this.cardBuilder,
    required this.scrollController,
    required this.onRetry,
    required this.onToggleOrder,
    required this.docs,
  });

  @override
  State<ListPageBody> createState() => _ListPageBodyState();
}

class _ListPageBodyState extends State<ListPageBody> {
  double _titleFontSize = 36;
  double _padding = 16;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      final offset = widget.scrollController.offset;
      final newSize = (36 - offset / 10).clamp(24.0, 36.0);
      final newPad = (16 - offset / 10).clamp(8.0, 16.0);
      if (newSize != _titleFontSize || newPad != _padding) {
        setState(() {
          _titleFontSize = newSize;
          _padding = newPad;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.all(_padding),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 100),
                  style: TextStyle(
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEEEEEE),
                  ),
                  child: const Text(
                    'Lista dei documenti :',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (!widget.isMobile) ...[
                const SizedBox(width: 16),
                ListDesktopButtons(
                  docs: widget.docs,
                  ascending: widget.ascending,
                  onToggleOrder: widget.onToggleOrder,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: widget.loading
              ? const Center(child: CircularProgressIndicator())
              : widget.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onRetry,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              : widget.documents.isEmpty
              ? const Center(
                  child: Text(
                    'Nessun documento',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListGroupedView(
                  documents: widget.documents,
                  isMobile: widget.isMobile,
                  ascending: widget.ascending,
                  cardBuilder: widget.cardBuilder,
                  scrollController: widget.scrollController,
                ),
        ),
      ],
    );
  }
}

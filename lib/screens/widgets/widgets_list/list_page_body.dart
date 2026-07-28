import 'dart:ui';
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
  final double _paddingTop = 24;
  double _paddingBottom = 16;
  double _paddingHorizontal = 32;
  late double _maxPad;

  double get _titleHeight => _titleFontSize + _paddingTop + _paddingBottom;
  @override
  void initState() {
    super.initState();
    _maxPad = widget.isMobile ? 32.0 : 48.0;
    _paddingHorizontal = _maxPad;
    widget.scrollController.addListener(() {
      final offset = widget.scrollController.offset;
      if (offset <= 0) {
        setState(() {
          _titleFontSize = 36;
          _paddingBottom = 16;
          _paddingHorizontal = _maxPad;
        });
        return;
      }
      final newSize = (36 - offset / 10).clamp(24.0, 36.0);
      final newPad = (_maxPad - offset / 10).clamp(16.0, _maxPad);
      if (newSize != _titleFontSize || newPad != _paddingBottom) {
        setState(() {
          _titleFontSize = newSize;
          _paddingBottom = newPad;
          _paddingHorizontal = newPad;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listContent = widget.loading
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
            titleHeight: _titleHeight,
            documents: widget.documents,
            isMobile: widget.isMobile,
            ascending: widget.ascending,
            cardBuilder: widget.cardBuilder,
            scrollController: widget.scrollController,
          );

    final bool showScrollbar =
        !widget.loading && widget.error == null && widget.documents.isNotEmpty;

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: _titleHeight),
            child: showScrollbar
                ? Scrollbar(
                    controller: widget.scrollController,
                    thumbVisibility: true,
                    child: listContent,
                  )
                : listContent,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.fromLTRB(
                  _paddingHorizontal,
                  _paddingTop,
                  _paddingHorizontal,
                  _paddingBottom,
                ),
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lista dei documenti :',
                        key: ValueKey(_titleFontSize),
                        textAlign: _titleFontSize < 36
                            ? TextAlign.start
                            : (widget.isMobile
                                  ? TextAlign.center
                                  : TextAlign.start),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFEEEEEE),
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
            ),
          ),
        ),
      ],
    );
  }
}

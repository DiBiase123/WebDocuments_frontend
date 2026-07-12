import 'package:flutter/material.dart';

class MonthSection extends StatefulWidget {
  final String month;
  final int docCount;
  final List<Widget> cards;
  const MonthSection({
    super.key,
    required this.month,
    required this.docCount,
    required this.cards,
  });

  @override
  State<MonthSection> createState() => _MonthSectionState();
}

class _MonthSectionState extends State<MonthSection> {
  static final Map<String, bool> _openMap = {};
  bool get _open => _openMap[widget.month] ?? true;
  void _toggle() {
    setState(() {
      _openMap[widget.month] = !_open;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF141E33),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 24,
                      color: t.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.month,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: t.colorScheme.primary.withAlpha(80),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.docCount} doc.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      color: t.colorScheme.primary,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                color: const Color(0xFF0F1629),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(children: widget.cards),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

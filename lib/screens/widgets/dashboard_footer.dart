import 'package:flutter/material.dart';

class DashboardFooter extends StatelessWidget {
  final VoidCallback onEnti;
  final VoidCallback onUtenti;
  final VoidCallback onUpload;
  final VoidCallback onList;

  const DashboardFooter({
    super.key,
    required this.onEnti,
    required this.onUtenti,
    required this.onUpload,
    required this.onList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white12)),
                ),
                child: InkWell(
                  splashColor: const Color(0xFFF08A5D).withAlpha(60),
                  highlightColor: const Color(0xFFF08A5D).withAlpha(30),
                  onTap: onList,
                  child: const Center(
                    child: Icon(Icons.list, color: Color(0xFFF08A5D)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white12)),
                ),
                child: InkWell(
                  splashColor: const Color(0xFFE43F5A).withAlpha(60),
                  highlightColor: const Color(0xFFE43F5A).withAlpha(30),
                  onTap: onUpload,
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xFFE43F5A)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white12)),
                ),
                child: InkWell(
                  splashColor: const Color(0xFFF08A5D).withAlpha(60),
                  highlightColor: const Color(0xFFF08A5D).withAlpha(30),
                  onTap: onEnti,
                  child: const Center(
                    child: Icon(Icons.business, color: Color(0xFFF08A5D)),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                child: InkWell(
                  splashColor: const Color(0xFF4ECDC4).withAlpha(60),
                  highlightColor: const Color(0xFF4ECDC4).withAlpha(30),
                  onTap: onUtenti,
                  child: const Center(
                    child: Icon(Icons.people, color: Color(0xFF4ECDC4)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

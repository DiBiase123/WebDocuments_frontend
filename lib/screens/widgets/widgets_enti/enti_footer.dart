import 'package:flutter/material.dart';

class EntiFooter extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAdd;

  const EntiFooter({super.key, required this.onBack, required this.onAdd});

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
                  onTap: onBack,
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Color(0xFFF08A5D)),
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
                  onTap: onAdd,
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xFFF08A5D)),
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

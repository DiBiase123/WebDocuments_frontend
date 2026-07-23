import 'package:flutter/material.dart';
import 'package:webdocuments/screens/pdf_by_ente.dart';
import 'package:webdocuments/screens/webdocuments_dashboard.dart';

class ListFooter extends StatelessWidget {
  final List<dynamic> docs;
  final bool isAdmin;
  final bool ascending;
  final VoidCallback onToggleOrder;
  const ListFooter({
    super.key,
    required this.docs,
    required this.isAdmin,
    required this.ascending,
    required this.onToggleOrder,
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PdfByEnte(docs: docs)),
                    );
                  },
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
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white12)),
                ),
                child: InkWell(
                  splashColor: const Color(0xFF4ECDC4).withAlpha(60),
                  highlightColor: const Color(0xFF4ECDC4).withAlpha(30),
                  onTap: onToggleOrder,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 22,
                          color: const Color(0xFF4ECDC4),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          ascending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 22,
                          color: const Color(0xFF4ECDC4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isAdmin)
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
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const WebDocumentsDashboard(),
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(Icons.dashboard, color: Color(0xFFE43F5A)),
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

import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_ente/pdf_ente_controller.dart';

class PdfEnteFooter extends StatelessWidget {
  final PdfEnteController ctrl;

  const PdfEnteFooter({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  onTap: () => Navigator.pop(context),
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
              child: InkWell(
                onTap: ctrl.toggleAscending,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ctrl.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 22,
                        color: const Color(0xFF4ECDC4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ctrl.ascending ? 'A-Z' : 'Z-A',
                        style: const TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

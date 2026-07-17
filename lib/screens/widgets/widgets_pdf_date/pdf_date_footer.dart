import 'package:flutter/material.dart';
import 'package:webdocuments/screens/widgets/widgets_pdf_date/pdf_date_controller.dart';

class PdfDateFooter extends StatelessWidget {
  final PdfDateController ctrl;

  const PdfDateFooter({super.key, required this.ctrl});

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
              child: Ink(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white12)),
                ),
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
                          ctrl.ascending ? 'Crescente' : 'Decrescente',
                          style: const TextStyle(
                            color: Color(0xFF4ECDC4),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: ctrl.toggleSortByEnte,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        ctrl.sortByEnte ? Icons.calendar_month : Icons.business,
                        size: 22,
                        color: const Color(0xFFF08A5D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ctrl.sortByEnte ? 'Date' : 'Enti',
                        style: const TextStyle(
                          color: Color(0xFFF08A5D),
                          fontSize: 14,
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

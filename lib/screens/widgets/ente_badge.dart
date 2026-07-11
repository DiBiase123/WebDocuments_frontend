import 'package:flutter/material.dart';

class EnteBadge extends StatelessWidget {
  final String nome;
  final double fontSize;

  const EnteBadge({super.key, required this.nome, this.fontSize = 16});

  static Color colorFromString(String s) {
    final colors = [
      const Color(0xFFE43F5A),
      const Color(0xFFF08A5D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
      const Color(0xFF6C5CE7),
      const Color(0xFFA8E6CF),
      const Color(0xFFFF6B6B),
      const Color(0xFF74B9FF),
    ];
    return colors[s.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFromString(nome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        nome,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

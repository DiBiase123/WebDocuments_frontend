import 'package:flutter/material.dart';

class EnteBadge extends StatelessWidget {
  final String nome;
  final double fontSize;

  const EnteBadge({super.key, required this.nome, this.fontSize = 16});

  static final List<Color> _colors = [
    const Color(0xFFE43F5A),
    const Color(0xFFF08A5D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFD93D),
    const Color(0xFF6C5CE7),
    const Color(0xFFA8E6CF),
    const Color(0xFFFF6B6B),
    const Color(0xFF74B9FF),
    const Color(0xFFFF9FF3),
    const Color(0xFF48DBFB),
    const Color(0xFFFECA57),
    const Color(0xFFFF6348),
  ];

  static final Map<String, Color> _colorMap = {};

  static Color colorFor(String nome) {
    if (_colorMap.containsKey(nome)) {
      return _colorMap[nome]!;
    }
    final index = _colorMap.length % _colors.length;
    final color = _colors[index];
    _colorMap[nome] = color;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(nome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B2F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        nome,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

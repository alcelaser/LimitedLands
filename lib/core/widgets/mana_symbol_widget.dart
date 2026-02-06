import 'package:flutter/material.dart';
import '../theme/color_tokens.dart';

class ManaSymbolWidget extends StatelessWidget {
  final String manaType;
  final double size;

  const ManaSymbolWidget({
    super.key,
    required this.manaType,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorTokens.getManaColor(manaType);
    final isWhite = manaType == 'W';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: isWhite
            ? Border.all(color: Colors.grey.shade400, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          manaType,
          style: TextStyle(
            color: isWhite || manaType == 'W'
                ? Colors.black87
                : Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

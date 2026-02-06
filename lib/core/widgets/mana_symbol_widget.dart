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

  static IconData _getManaIcon(String manaType) {
    switch (manaType) {
      case 'W':
        return Icons.wb_sunny;
      case 'U':
        return Icons.water_drop;
      case 'B':
        return Icons.dark_mode;
      case 'R':
        return Icons.local_fire_department;
      case 'G':
        return Icons.park;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = ColorTokens.getManaColor(manaType);
    final isWhite = manaType == 'W';
    final icon = _getManaIcon(manaType);

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
        child: Icon(
          icon,
          color: isWhite ? Colors.black87 : Colors.white,
          size: size * 0.55,
        ),
      ),
    );
  }
}

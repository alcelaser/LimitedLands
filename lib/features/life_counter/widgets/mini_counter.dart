import 'package:flutter/material.dart';

class MiniCounter extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String label;

  const MiniCounter({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
    required this.onLongPress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              value > 0 ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value > 0 ? color.withOpacity(0.4) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: value > 0 ? color : Colors.white38),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: value > 0 ? color : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

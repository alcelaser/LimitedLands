import 'package:flutter/material.dart';

class LifeTapZone extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget child;

  const LifeTapZone({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.child,
  });

  @override
  State<LifeTapZone> createState() => _LifeTapZoneState();
}

class _LifeTapZoneState extends State<LifeTapZone> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _isPressed ? Colors.white.withOpacity(0.08) : Colors.transparent,
        child: Center(child: widget.child),
      ),
    );
  }
}

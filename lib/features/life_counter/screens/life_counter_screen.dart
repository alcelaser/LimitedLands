import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/life_counter_provider.dart';

class LifeCounterScreen extends ConsumerWidget {
  const LifeCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifeCounterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Player 2 (top, rotated 180°)
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: _PlayerPanel(
                  player: 2,
                  life: state.player2.life,
                  poison: state.player2.poison,
                  experience: state.player2.experience,
                  color: const Color(0xFF1B2838),
                  accentColor: const Color(0xFF4DA3E0),
                ),
              ),
            ),
            // Center divider with reset button
            _CenterDivider(onReset: () {
              HapticFeedback.heavyImpact();
              ref.read(lifeCounterProvider.notifier).reset();
            }),
            // Player 1 (bottom)
            Expanded(
              child: _PlayerPanel(
                player: 1,
                life: state.player1.life,
                poison: state.player1.poison,
                experience: state.player1.experience,
                color: const Color(0xFF1A1A2E),
                accentColor: const Color(0xFFC9A96E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterDivider extends StatelessWidget {
  final VoidCallback onReset;

  const _CenterDivider({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.black,
      child: Center(
        child: GestureDetector(
          onTap: onReset,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF252540),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white54, size: 18),
                SizedBox(width: 6),
                Text(
                  'RESET',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerPanel extends ConsumerWidget {
  final int player;
  final int life;
  final int poison;
  final int experience;
  final Color color;
  final Color accentColor;

  const _PlayerPanel({
    required this.player,
    required this.life,
    required this.poison,
    required this.experience,
    required this.color,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: color,
      child: Column(
        children: [
          // Poison & Experience counters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniCounter(
                  icon: Icons.coronavirus,
                  value: poison,
                  color: poison >= 10
                      ? Colors.red.shade400
                      : poison >= 7
                          ? Colors.orange.shade300
                          : Colors.green.shade300,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(lifeCounterProvider.notifier).changePoison(player, 1);
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    ref.read(lifeCounterProvider.notifier).changePoison(player, -1);
                  },
                  label: 'Poison',
                ),
                const SizedBox(width: 24),
                _MiniCounter(
                  icon: Icons.star,
                  value: experience,
                  color: Colors.amber.shade300,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(lifeCounterProvider.notifier).changeExperience(player, 1);
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    ref.read(lifeCounterProvider.notifier).changeExperience(player, -1);
                  },
                  label: 'Experience',
                ),
              ],
            ),
          ),
          // Life total area
          Expanded(
            child: Row(
              children: [
                // Minus button (left half)
                Expanded(
                  child: _LifeTapZone(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(lifeCounterProvider.notifier).changeLife(player, -1);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      ref.read(lifeCounterProvider.notifier).changeLife(player, -5);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Icon(
                          Icons.remove_rounded,
                          color: accentColor.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                // Life total (center)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Text(
                    '$life',
                    key: ValueKey('p${player}_$life'),
                    style: TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w200,
                      color: life <= 0
                          ? Colors.red.shade400
                          : life <= 5
                              ? Colors.orange.shade300
                              : Colors.white,
                      height: 1,
                    ),
                  ),
                ),
                // Plus button (right half)
                Expanded(
                  child: _LifeTapZone(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(lifeCounterProvider.notifier).changeLife(player, 1);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      ref.read(lifeCounterProvider.notifier).changeLife(player, 5);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Icon(
                          Icons.add_rounded,
                          color: accentColor.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTapZone extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget child;

  const _LifeTapZone({
    required this.onTap,
    required this.onLongPress,
    required this.child,
  });

  @override
  State<_LifeTapZone> createState() => _LifeTapZoneState();
}

class _LifeTapZoneState extends State<_LifeTapZone> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _isPressed ? Colors.white.withOpacity(0.05) : Colors.transparent,
        child: Center(child: widget.child),
      ),
    );
  }
}

class _MiniCounter extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final String label;

  const _MiniCounter({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: value > 0 ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value > 0 ? color.withOpacity(0.4) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: value > 0 ? color : Colors.white38),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
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

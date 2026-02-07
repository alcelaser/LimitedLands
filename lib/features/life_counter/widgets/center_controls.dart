import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_timer_provider.dart';

class CenterControls extends ConsumerWidget {
  final int turnNumber;
  final String activePlayerName;
  final VoidCallback onNextTurn;
  final VoidCallback onMenu;
  final VoidCallback onReset;
  final VoidCallback? onDice;
  final VoidCallback? onHighRoll;

  const CenterControls({
    super.key,
    required this.turnNumber,
    required this.activePlayerName,
    required this.onNextTurn,
    required this.onMenu,
    required this.onReset,
    this.onDice,
    this.onHighRoll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(gameTimerProvider);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active player name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activePlayerName,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Main controls row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menu / exit button
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white70, size: 20),
                  onPressed: onMenu,
                  tooltip: 'Menu',
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
                // Reset button
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70,
                      size: 20),
                  onPressed: onReset,
                  tooltip: 'Reset',
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
                // Dice button
                if (onDice != null)
                  IconButton(
                    icon: const Icon(Icons.casino, color: Colors.white70,
                        size: 20),
                    onPressed: onDice,
                    tooltip: 'Dice',
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                  ),
                // Turn counter
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'T$turnNumber',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Next turn button
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white70,
                      size: 20),
                  onPressed: onNextTurn,
                  tooltip: 'Next Turn',
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Timer row (only visible when timer has been used)
          if (timerState.isRunning || timerState.elapsed > Duration.zero)
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play/pause button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final notifier = ref.read(gameTimerProvider.notifier);
                    if (timerState.isRunning) {
                      notifier.pause();
                    } else if (timerState.elapsed > Duration.zero) {
                      notifier.resume();
                    } else {
                      notifier.start(0);
                    }
                  },
                  child: Icon(
                    timerState.isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 4),
                // Elapsed time
                Text(
                  timerState.formattedElapsed,
                  style: TextStyle(
                    color: timerState.isRunning
                        ? Colors.white70
                        : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
                // Reset timer
                if (timerState.elapsed > Duration.zero) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameTimerProvider.notifier).reset();
                    },
                    child: const Icon(
                      Icons.timer_off,
                      color: Colors.white38,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

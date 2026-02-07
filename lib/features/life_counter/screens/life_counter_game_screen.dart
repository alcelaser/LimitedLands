import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/game_provider.dart';
import '../providers/game_timer_provider.dart';
import '../widgets/player_grid.dart';
import '../widgets/center_controls.dart';
import '../widgets/dice_dialog.dart';
import '../widgets/high_roll_dialog.dart';
import '../widgets/planechase_overlay.dart';

class LifeCounterGameScreen extends ConsumerStatefulWidget {
  const LifeCounterGameScreen({super.key});

  @override
  ConsumerState<LifeCounterGameScreen> createState() =>
      _LifeCounterGameScreenState();
}

class _LifeCounterGameScreenState
    extends ConsumerState<LifeCounterGameScreen> {
  @override
  void initState() {
    super.initState();
    // Enter immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _showExitDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text(
            'Your game will be saved. You can resume it later from the setup screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(gameTimerProvider.notifier).pause();
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    if (!gameState.isGameActive || gameState.players.isEmpty) {
      // If navigated here without active game, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(body: SizedBox.expand());
    }

    final activePlayer = gameState.players[gameState.activePlayerIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Player grid fills the screen
            PlayerGrid(
              players: gameState.players,
              activePlayerIndex: gameState.activePlayerIndex,
            ),
            // Center controls overlay
            CenterControls(
              turnNumber: gameState.turnNumber,
              activePlayerName: activePlayer.name,
              onNextTurn: () {
                HapticFeedback.mediumImpact();
                ref.read(gameProvider.notifier).nextTurn();
                // Sync timer with new active player
                final newState = ref.read(gameProvider);
                ref
                    .read(gameTimerProvider.notifier)
                    .switchTurn(newState.activePlayerIndex);
              },
              onMenu: _showExitDialog,
              onDice: () {
                HapticFeedback.lightImpact();
                showDialog(
                  context: context,
                  builder: (_) => const DiceDialog(),
                );
              },
              onHighRoll: () {
                HapticFeedback.lightImpact();
                showDialog(
                  context: context,
                  builder: (_) => const HighRollDialog(),
                );
              },
              onReset: () {
                HapticFeedback.heavyImpact();
                showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Game?'),
                    content: const Text(
                        'All life totals and counters will be reset.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(gameProvider.notifier).resetGame();
                          ref.read(gameTimerProvider.notifier).reset();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Planechase overlay (if enabled)
            if (gameState.config.planechaseEnabled)
              const PlanechaseOverlay(),
          ],
        ),
      ),
    );
  }
}

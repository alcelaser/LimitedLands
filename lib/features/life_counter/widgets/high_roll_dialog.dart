import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dice_model.dart';
import '../providers/dice_provider.dart';
import '../providers/game_provider.dart';

class HighRollDialog extends ConsumerStatefulWidget {
  const HighRollDialog({super.key});

  @override
  ConsumerState<HighRollDialog> createState() => _HighRollDialogState();
}

class _HighRollDialogState extends ConsumerState<HighRollDialog> {
  @override
  void initState() {
    super.initState();
    final playerCount = ref.read(gameProvider).players.length;
    ref.read(highRollProvider.notifier).initialize(playerCount);
  }

  @override
  Widget build(BuildContext context) {
    final highRollState = ref.watch(highRollProvider);
    final gameState = ref.watch(gameProvider);

    return AlertDialog(
      title: const Text('Who Goes First?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Each player rolls a D20. Highest roll goes first.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in highRollState.playerRolls.entries) ...[
            _PlayerRollRow(
              playerName: gameState.players[entry.key].name,
              playerIndex: entry.key,
              roll: entry.value,
              isWinner: highRollState.winnerIndex == entry.key,
              onRoll: entry.value == null
                  ? () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(highRollProvider.notifier)
                          .rollForPlayer(entry.key);
                    }
                  : null,
            ),
          ],
          const SizedBox(height: 16),
          if (highRollState.isComplete && highRollState.winnerIndex != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.players[highRollState.winnerIndex!].name} goes first!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_allRolled(highRollState) && !highRollState.isComplete) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tie! Roll again to break it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(highRollProvider.notifier).reset();
          },
          child: const Text('Re-roll All'),
        ),
        if (!highRollState.isComplete)
          OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(highRollProvider.notifier).rollAll();
            },
            child: const Text('Roll All'),
          ),
        if (highRollState.isComplete && highRollState.winnerIndex != null)
          FilledButton(
            onPressed: () {
              ref
                  .read(gameProvider.notifier)
                  .setActivePlayer(highRollState.winnerIndex!);
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          )
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  bool _allRolled(HighRollState state) {
    return state.playerRolls.values.every((v) => v != null);
  }
}

class _PlayerRollRow extends StatelessWidget {
  final String playerName;
  final int playerIndex;
  final int? roll;
  final bool isWinner;
  final VoidCallback? onRoll;

  const _PlayerRollRow({
    required this.playerName,
    required this.playerIndex,
    required this.roll,
    required this.isWinner,
    this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (isWinner)
            const Icon(Icons.emoji_events, color: Colors.amber, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              playerName,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                color: isWinner ? Colors.amber.shade300 : Colors.white70,
              ),
            ),
          ),
          if (roll != null)
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$roll',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.amber.shade300 : Colors.white,
                ),
              ),
            )
          else
            SizedBox(
              width: 60,
              height: 32,
              child: OutlinedButton(
                onPressed: onRoll,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Roll'),
              ),
            ),
        ],
      ),
    );
  }
}

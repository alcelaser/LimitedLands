import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_model.dart';
import '../providers/game_provider.dart';

class CommanderDamageView extends ConsumerWidget {
  final int targetIndex;

  const CommanderDamageView({super.key, required this.targetIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final target = gameState.players[targetIndex];
    final partnerEnabled = gameState.config.partnerEnabled;

    // All other players are potential commander damage sources
    final sources = <PlayerState>[];
    for (int i = 0; i < gameState.players.length; i++) {
      if (i != targetIndex) sources.add(gameState.players[i]);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Commander Damage to ${target.name}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              for (final source in sources) ...[
                _DamageRow(
                  sourceName: source.name,
                  label: 'Commander',
                  value: target.commanderDamageReceived[source.id] ?? 0,
                  isLethal:
                      (target.commanderDamageReceived[source.id] ?? 0) >= 21,
                  onIncrement: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(gameProvider.notifier)
                        .recordCommanderDamage(targetIndex, source.id, 1);
                  },
                  onDecrement: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(gameProvider.notifier)
                        .recordCommanderDamage(targetIndex, source.id, -1);
                  },
                ),
                if (partnerEnabled)
                  _DamageRow(
                    sourceName: source.name,
                    label: 'Partner',
                    value: target.partnerDamageReceived[source.id] ?? 0,
                    isLethal:
                        (target.partnerDamageReceived[source.id] ?? 0) >= 21,
                    onIncrement: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(gameProvider.notifier)
                          .recordPartnerDamage(targetIndex, source.id, 1);
                    },
                    onDecrement: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(gameProvider.notifier)
                          .recordPartnerDamage(targetIndex, source.id, -1);
                    },
                  ),
                const Divider(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DamageRow extends StatelessWidget {
  final String sourceName;
  final String label;
  final int value;
  final bool isLethal;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _DamageRow({
    required this.sourceName,
    required this.label,
    required this.value,
    required this.isLethal,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLethal ? Colors.red.shade400 : Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sourceName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: onDecrement,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: onIncrement,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          if (isLethal)
            const Icon(Icons.warning, color: Colors.red, size: 20),
        ],
      ),
    );
  }
}

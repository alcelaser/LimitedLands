import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mtg_constants.dart';
import '../providers/game_provider.dart';

class CounterSuiteSheet extends ConsumerWidget {
  final int playerIndex;

  const CounterSuiteSheet({super.key, required this.playerIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(
      gameProvider.select((s) => s.players[playerIndex]),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
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
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${player.name} Counters',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Poison
              _CounterRow(
                icon: Icons.coronavirus,
                label: 'Poison',
                value: player.poison,
                color: player.isPoisonLethal
                    ? Colors.red.shade400
                    : Colors.green.shade300,
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).changePoison(playerIndex, 1);
                },
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).changePoison(playerIndex, -1);
                },
              ),
              // Experience
              _CounterRow(
                icon: Icons.star,
                label: 'Experience',
                value: player.experience,
                color: Colors.amber.shade300,
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeExperience(playerIndex, 1);
                },
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeExperience(playerIndex, -1);
                },
              ),
              // Energy
              _CounterRow(
                icon: Icons.bolt,
                label: 'Energy',
                value: player.energy,
                color: Colors.orange.shade300,
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).changeEnergy(playerIndex, 1);
                },
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).changeEnergy(playerIndex, -1);
                },
              ),
              // Storm Count
              _CounterRow(
                icon: Icons.flash_on,
                label: 'Storm',
                value: player.stormCount,
                color: Colors.purple.shade300,
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeStormCount(playerIndex, 1);
                },
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeStormCount(playerIndex, -1);
                },
              ),
              // Commander Tax
              _CounterRow(
                icon: Icons.shield,
                label: 'Cmd Tax',
                value: player.commanderTax,
                color: Colors.cyan.shade300,
                onIncrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeCommanderTax(playerIndex, 1);
                },
                onDecrement: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(gameProvider.notifier)
                      .changeCommanderTax(playerIndex, -1);
                },
              ),
              const Divider(height: 24),
              // Mana pool
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mana Pool',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final mana in MtgConstants.manaPoolTypes)
                    _ManaButton(
                      type: mana,
                      value: player.manaPool[mana] ?? 0,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(gameProvider.notifier)
                            .changeMana(playerIndex, mana, 1);
                      },
                      onLongPress: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(gameProvider.notifier)
                            .changeMana(playerIndex, mana, -1);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).clearManaPool(playerIndex);
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear Mana'),
              ),
              const Divider(height: 24),
              // Custom counters
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Custom Counters',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              for (final counter in player.customCounters)
                _CounterRow(
                  icon: Icons.tag,
                  label: counter.label,
                  value: counter.value,
                  color: Colors.teal.shade300,
                  onIncrement: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(gameProvider.notifier)
                        .changeCustomCounter(playerIndex, counter.id, 1);
                  },
                  onDecrement: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(gameProvider.notifier)
                        .changeCustomCounter(playerIndex, counter.id, -1);
                  },
                  onRemove: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(gameProvider.notifier)
                        .removeCustomCounter(playerIndex, counter.id);
                  },
                ),
              TextButton.icon(
                onPressed: () => _showAddCounterDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Counter'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCounterDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Counter'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Counter name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final label = controller.text.trim();
              if (label.isNotEmpty) {
                ref
                    .read(gameProvider.notifier)
                    .addCustomCounter(playerIndex, label);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onRemove;

  const _CounterRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onIncrement,
    required this.onDecrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: onDecrement,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: value > 0 ? color : Colors.white38,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: onIncrement,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.red.shade300),
              onPressed: onRemove,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

class _ManaButton extends StatelessWidget {
  final String type;
  final int value;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ManaButton({
    required this.type,
    required this.value,
    required this.onTap,
    required this.onLongPress,
  });

  static const _manaColors = {
    'W': Color(0xFFF9FAF4),
    'U': Color(0xFF0E68AB),
    'B': Color(0xFF150B00),
    'R': Color(0xFFD3202A),
    'G': Color(0xFF00733E),
    'C': Color(0xFF9E9E9E),
  };

  @override
  Widget build(BuildContext context) {
    final color = _manaColors[type] ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: value > 0 ? color.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: value > 0 ? color.withOpacity(0.6) : Colors.white12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value > 0 ? color : Colors.white38,
              ),
            ),
            if (value > 0)
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mtg_constants.dart';
import '../providers/game_provider.dart';

class PlayerSettingsSheet extends ConsumerStatefulWidget {
  final int playerIndex;

  const PlayerSettingsSheet({super.key, required this.playerIndex});

  @override
  ConsumerState<PlayerSettingsSheet> createState() =>
      _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends ConsumerState<PlayerSettingsSheet> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final player = ref.read(gameProvider).players[widget.playerIndex];
    _nameController = TextEditingController(text: player.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(
      gameProvider.select((s) => s.players[widget.playerIndex]),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
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
                'Player Settings',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Player name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) {
                    ref
                        .read(gameProvider.notifier)
                        .setPlayerName(widget.playerIndex, value.trim());
                  }
                },
              ),
              const SizedBox(height: 20),
              // Color picker
              Text(
                'Player Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < MtgConstants.playerColors.length; i++)
                    _ColorCircle(
                      color: Color(MtgConstants.playerColors[i]),
                      isSelected: player.colorIndex == i,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(gameProvider.notifier)
                            .setPlayerColor(widget.playerIndex, i);
                      },
                    ),
                ],
              ),
              const Divider(height: 32),
              // Kill / Revive
              ListTile(
                leading: Icon(
                  player.isAlive ? Icons.dangerous : Icons.favorite,
                  color: player.isAlive
                      ? Colors.red.shade400
                      : Colors.green.shade400,
                ),
                title: Text(
                  player.isAlive ? 'Kill Player' : 'Revive Player',
                ),
                subtitle: Text(
                  player.isAlive
                      ? 'Mark player as eliminated'
                      : 'Bring player back into the game',
                ),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(gameProvider.notifier)
                      .togglePlayerAlive(widget.playerIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.white24, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

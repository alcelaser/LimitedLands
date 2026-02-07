import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/mtg_constants.dart';
import '../../../core/routing/route_names.dart';
import '../models/game_state_model.dart';
import '../providers/game_provider.dart';
import '../providers/game_setup_provider.dart';
import '../widgets/dice_dialog.dart';
import '../widgets/high_roll_dialog.dart';

class GameSetupScreen extends ConsumerWidget {
  const GameSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(gameSetupProvider);
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Counter'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resume active game banner
          if (gameState.isGameActive) ...[
            Card(
              color: theme.colorScheme.primaryContainer,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pushNamed(RouteNames.lifeCounterGame);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Game in Progress',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${gameState.players.length} players \u2022 Turn ${gameState.turnNumber}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Format selector
          Text('Format', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<GameFormat>(
            segments: const [
              ButtonSegment(
                value: GameFormat.standard,
                label: Text('Standard'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment(
                value: GameFormat.commander,
                label: Text('Commander'),
                icon: Icon(Icons.shield),
              ),
              ButtonSegment(
                value: GameFormat.custom,
                label: Text('Custom'),
                icon: Icon(Icons.tune),
              ),
            ],
            selected: {config.format},
            onSelectionChanged: (selected) {
              HapticFeedback.lightImpact();
              ref.read(gameSetupProvider.notifier).setFormat(selected.first);
            },
          ),
          const SizedBox(height: 24),

          // Player count
          Text('Players', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filled(
                onPressed: config.playerCount > MtgConstants.minPlayers
                    ? () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(gameSetupProvider.notifier)
                            .setPlayerCount(config.playerCount - 1);
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${config.playerCount}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: config.playerCount < MtgConstants.maxPlayers
                    ? () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(gameSetupProvider.notifier)
                            .setPlayerCount(config.playerCount + 1);
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Starting life
          Text('Starting Life', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (config.format == GameFormat.custom) ...[
            Row(
              children: [
                IconButton.filled(
                  onPressed: config.startingLife > 1
                      ? () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(gameSetupProvider.notifier)
                              .setStartingLife(config.startingLife - 1);
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${config.startingLife}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(gameSetupProvider.notifier)
                        .setStartingLife(config.startingLife + 1);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${config.startingLife}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Options
          Text('Options', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (config.format == GameFormat.commander) ...[
            SwitchListTile(
              title: const Text('Partner Commanders'),
              subtitle:
                  const Text('Track damage from two commanders per player'),
              value: config.partnerEnabled,
              onChanged: (_) {
                HapticFeedback.lightImpact();
                ref.read(gameSetupProvider.notifier).togglePartner();
              },
            ),
          ],
          SwitchListTile(
            title: const Text('Planechase'),
            subtitle: const Text('Include planar deck and die'),
            value: config.planechaseEnabled,
            onChanged: (_) {
              HapticFeedback.lightImpact();
              ref.read(gameSetupProvider.notifier).togglePlanechase();
            },
          ),
          const SizedBox(height: 32),

          // Quick tools
          Text('Quick Tools', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showDialog(
                      context: context,
                      builder: (_) => const DiceDialog(),
                    );
                  },
                  icon: const Icon(Icons.casino),
                  label: const Text('Dice'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showDialog(
                      context: context,
                      builder: (_) => const HighRollDialog(),
                    );
                  },
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('High Roll'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Start game button
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(gameProvider.notifier).startGame(config);
              context.pushNamed(RouteNames.lifeCounterGame);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Game'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

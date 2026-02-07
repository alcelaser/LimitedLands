import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_model.dart';
import '../providers/game_provider.dart';
import 'counter_suite_sheet.dart';
import 'commander_damage_view.dart';
import 'keypad_dialog.dart';
import 'life_tap_zone.dart';
import 'mini_counter.dart';
import 'player_settings_sheet.dart';

class PlayerPanel extends ConsumerWidget {
  final int playerIndex;
  final PlayerState player;
  final bool isActive;
  final Color backgroundColor;

  const PlayerPanel({
    super.key,
    required this.playerIndex,
    required this.player,
    required this.isActive,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDead = !player.isAlive;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 300) {
          // Swipe right -> commander damage
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CommanderDamageView(targetIndex: playerIndex),
          );
        } else if (velocity < -300) {
          // Swipe left -> player settings
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PlayerSettingsSheet(playerIndex: playerIndex),
          );
        }
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          // Swipe down -> counter suite
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CounterSuiteSheet(playerIndex: playerIndex),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDead ? backgroundColor.withOpacity(0.3) : backgroundColor,
          border: isActive
              ? Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Active player glow
            if (isActive && !isDead)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            // Main content
            Column(
              children: [
                // Player name + mini counters row
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
                  child: Row(
                    children: [
                      // Player name
                      Expanded(
                        child: Text(
                          player.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Mini counters
                      if (player.poison > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: MiniCounter(
                            icon: Icons.coronavirus,
                            value: player.poison,
                            color: player.isPoisonLethal
                                ? Colors.red.shade400
                                : Colors.green.shade300,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changePoison(playerIndex, 1);
                            },
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changePoison(playerIndex, -1);
                            },
                            label: 'Poison',
                          ),
                        ),
                      if (player.experience > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: MiniCounter(
                            icon: Icons.star,
                            value: player.experience,
                            color: Colors.amber.shade300,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changeExperience(playerIndex, 1);
                            },
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changeExperience(playerIndex, -1);
                            },
                            label: 'Experience',
                          ),
                        ),
                      if (player.energy > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: MiniCounter(
                            icon: Icons.bolt,
                            value: player.energy,
                            color: Colors.orange.shade300,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changeEnergy(playerIndex, 1);
                            },
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .changeEnergy(playerIndex, -1);
                            },
                            label: 'Energy',
                          ),
                        ),
                    ],
                  ),
                ),
                // Life total area
                Expanded(
                  child: Row(
                    children: [
                      // Minus tap zone (left half)
                      Expanded(
                        child: LifeTapZone(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(gameProvider.notifier)
                                .changeLife(playerIndex, -1);
                          },
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(gameProvider.notifier)
                                .changeLife(playerIndex, -10);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(
                                Icons.remove_rounded,
                                color: Colors.white.withOpacity(0.2),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Life total (center) — double-tap for keypad
                      GestureDetector(
                        onDoubleTap: () async {
                          HapticFeedback.mediumImpact();
                          final result = await showDialog<int>(
                            context: context,
                            builder: (_) => KeypadDialog(
                              currentValue: player.life,
                              playerName: player.name,
                            ),
                          );
                          if (result != null) {
                            ref
                                .read(gameProvider.notifier)
                                .setLife(playerIndex, result);
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                  scale: animation, child: child),
                            );
                          },
                          child: Text(
                            '${player.life}',
                            key: ValueKey('p${playerIndex}_${player.life}'),
                            style: TextStyle(
                              fontSize: _lifeFontSize(context),
                              fontWeight: FontWeight.w200,
                              color: _lifeColor(),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      // Plus tap zone (right half)
                      Expanded(
                        child: LifeTapZone(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref
                                .read(gameProvider.notifier)
                                .changeLife(playerIndex, 1);
                          },
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(gameProvider.notifier)
                                .changeLife(playerIndex, 10);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white.withOpacity(0.2),
                                size: 28,
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
            // Dead overlay
            if (isDead)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Icon(
                      Icons.dangerous,
                      color: Colors.white38,
                      size: 48,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _lifeColor() {
    if (player.life <= 0) return Colors.red.shade400;
    if (player.life <= 5) return Colors.orange.shade300;
    return Colors.white;
  }

  double _lifeFontSize(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 400) return 48;
    if (height < 600) return 64;
    return 80;
  }
}

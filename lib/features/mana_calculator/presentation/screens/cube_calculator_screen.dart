import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mtg_constants.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/mana_symbol_widget.dart';
import '../providers/cube_calculator_provider.dart';

class CubeCalculatorScreen extends ConsumerWidget {
  const CubeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cubeCalculatorProvider);
    final notifier = ref.read(cubeCalculatorProvider.notifier);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _CubeDeckConfig(state: state, notifier: notifier),
              const SizedBox(height: 12),
              _CubeManaInput(state: state, notifier: notifier),
              const SizedBox(height: 12),
              _ManaSourceSection(
                title: 'Fast Mana',
                subtitle: 'Free mana sources (0 cost)',
                icon: Icons.flash_on,
              iconColor: Colors.amber,
              sources: state.fastManaSources,
              onToggle: notifier.toggleFastMana,
              onReset: notifier.resetFastMana,
            ),
            const SizedBox(height: 12),
            // Paid mana
            _ManaSourceSection(
              title: 'Mana Rocks',
              subtitle: 'Paid mana sources',
              icon: Icons.diamond_outlined,
              iconColor: Colors.blueGrey.shade300,
              sources: state.paidManaSources,
              onToggle: notifier.togglePaidMana,
              onReset: notifier.resetPaidMana,
            ),
            const SizedBox(height: 12),
            // Output
            _CubeOutput(state: state),
            const SizedBox(height: 24),
          ],
        ),
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton.small(
          heroTag: 'cube_reset',
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.reset();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    ]);
  }
}

class _CubeDeckConfig extends StatelessWidget {
  final CubeCalculatorState state;
  final CubeCalculatorNotifier notifier;

  const _CubeDeckConfig({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Configuration',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            _ConfigRow(
              label: 'Deck Size',
              value: state.deckSize,
              onIncrement: () => notifier.updateDeckSize(state.deckSize + 1),
              onDecrement: () => notifier.updateDeckSize(state.deckSize - 1),
            ),
            const SizedBox(height: 8),
            _ConfigRow(
              label: 'Total Mana Sources',
              value: state.targetManaSourceCount,
              onIncrement: () => notifier
                  .updateTargetManaSourceCount(state.targetManaSourceCount + 1),
              onDecrement: () => notifier
                  .updateTargetManaSourceCount(state.targetManaSourceCount - 1),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Artifact mana: ${state.totalNonLandMana}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white54)),
                Text('Lands needed: ${state.landsNeeded}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CubeManaInput extends StatelessWidget {
  final CubeCalculatorState state;
  final CubeCalculatorNotifier notifier;

  const _CubeManaInput({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final totalSymbols =
        state.symbolCounts.values.fold<int>(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Mana Symbols',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('Total: $totalSymbols',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 12),
            ...MtgConstants.manaTypes.map((type) {
              final count = state.symbolCounts[type] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ManaSymbolWidget(manaType: type, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(MtgConstants.manaNames[type]!,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    _MiniStepper(
                      value: count,
                      onDecrement: count > 0
                          ? () {
                              HapticFeedback.lightImpact();
                              notifier.decrementSymbol(type);
                            }
                          : null,
                      onIncrement: () {
                        HapticFeedback.lightImpact();
                        notifier.incrementSymbol(type);
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ManaSourceSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<CubeManaSource> sources;
  final void Function(int) onToggle;
  final void Function(int) onReset;

  const _ManaSourceSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.sources,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = sources.fold<int>(0, (sum, s) => sum + s.count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('$subtitle  •  Tap +1, hold to reset',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalCount > 0
                        ? iconColor.withOpacity(0.15)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCount',
                    style: TextStyle(
                      color: totalCount > 0 ? iconColor : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(sources.length, (i) {
                final source = sources[i];
                final isActive = source.count > 0;
                final produces = source.colorsProduced;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onToggle(i);
                  },
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    onReset(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? iconColor.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? iconColor.withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: source.count > 1
                                ? Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: iconColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${source.count}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Icon(Icons.check_circle,
                                    size: 16, color: iconColor),
                          ),
                        Text(
                          source.name,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white54,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        if (produces.isNotEmpty && produces.length <= 2) ...[
                          const SizedBox(width: 6),
                          ...produces.map((c) => Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: ManaSymbolWidget(manaType: c, size: 14),
                              )),
                        ],
                        if (produces.isEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 10, color: Colors.grey.shade500),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CubeOutput extends StatelessWidget {
  final CubeCalculatorState state;

  const _CubeOutput({required this.state});

  @override
  Widget build(BuildContext context) {
    final rec = state.recommendation;

    if (rec.landCounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.landscape_outlined,
                    size: 48, color: Colors.white24),
                const SizedBox(height: 12),
                Text(
                  'Enter mana symbols and select your mana rocks',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.landscape,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Land Recommendations',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(rec.totalLands),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${rec.totalLands} lands',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                ),
              ],
            ),
            if (rec.totalManaSourcesIncludingLands > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${rec.totalManaSourcesIncludingLands} total mana sources (${state.totalNonLandMana} artifact + ${rec.totalLands} land)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
              ),
            const SizedBox(height: 16),
            ...rec.landCounts.map((lc) {
              final landName =
                  MtgConstants.basicLandNames[lc.manaType] ?? 'Unknown';
              final color = ColorTokens.getManaColorLight(lc.manaType);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ManaSymbolWidget(manaType: lc.manaType, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                landName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: lc.isSplash
                                            ? Colors.white54
                                            : Colors.white),
                              ),
                              if (lc.isSplash) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('SPLASH',
                                      style: TextStyle(
                                          color: Colors.amber.shade300,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween:
                                  Tween(begin: 0, end: lc.percentage),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) {
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.white10,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${lc.count}',
                        key: ValueKey(lc.count),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (rec.tips.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              ...rec.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.lightBlueAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(tip,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Colors.lightBlue.shade200)),
                        ),
                      ],
                    ),
                  )),
            ],
            if (rec.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...rec.warnings.map((warning) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(warning,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.amber.shade200)),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ConfigRow({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.titleMedium)),
        _MiniStepper(
          value: value,
          onDecrement: () {
            HapticFeedback.lightImpact();
            onDecrement();
          },
          onIncrement: () {
            HapticFeedback.lightImpact();
            onIncrement();
          },
        ),
      ],
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _MiniStepper({
    required this.value,
    this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallButton(
          icon: Icons.remove,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 44,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$value',
              key: ValueKey(value),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        _SmallButton(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SmallButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: onTap != null
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.white12,
            ),
          ),
          child: Icon(icon,
              color: onTap != null
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white24,
              size: 18),
        ),
      ),
    );
  }
}

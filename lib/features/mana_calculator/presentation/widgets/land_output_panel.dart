import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mtg_constants.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../../../core/widgets/mana_symbol_widget.dart';
import '../../domain/models/mana_input.dart';
import '../providers/mana_calculator_provider.dart';

class LandOutputPanel extends ConsumerWidget {
  const LandOutputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manaCalculatorProvider);
    final recommendation = state.recommendation;

    if (recommendation.landCounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.landscape_outlined,
                  size: 48,
                  color: Colors.white24,
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter mana symbols above to get land recommendations',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white38,
                      ),
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
                Icon(
                  Icons.landscape,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Land Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(recommendation.totalLands),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${recommendation.totalLands} lands',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendation.landCounts.map(
              (landCount) => _LandOutputRow(landCount: landCount),
            ),
            if (recommendation.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              ...recommendation.warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.amber.shade200,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LandOutputRow extends StatelessWidget {
  final LandCount landCount;

  const _LandOutputRow({required this.landCount});

  @override
  Widget build(BuildContext context) {
    final landName =
        MtgConstants.basicLandNames[landCount.manaType] ?? 'Unknown';
    final color = ColorTokens.getManaColorLight(landCount.manaType);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ManaSymbolWidget(manaType: landCount.manaType, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      landName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: landCount.isSplash
                                    ? Colors.white54
                                    : Colors.white,
                              ),
                    ),
                    if (landCount.isSplash) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SPLASH',
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: landCount.percentage),
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
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              '${landCount.count}',
              key: ValueKey(landCount.count),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

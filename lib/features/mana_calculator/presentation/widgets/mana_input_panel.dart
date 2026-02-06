import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mtg_constants.dart';
import '../providers/mana_calculator_provider.dart';
import 'mana_input_row.dart';

class ManaInputPanel extends ConsumerWidget {
  const ManaInputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manaCalculatorProvider);
    final notifier = ref.read(manaCalculatorProvider.notifier);
    final totalSymbols = state.input.symbolCounts.values
        .fold<int>(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mana Symbols',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Container(
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
                    'Total: $totalSymbols',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the number of colored mana symbols in your non-land cards',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...MtgConstants.manaTypes.map((manaType) => ManaInputRow(
                  manaType: manaType,
                  count: state.input.symbolCounts[manaType] ?? 0,
                  onIncrement: () => notifier.incrementSymbol(manaType),
                  onDecrement: () => notifier.decrementSymbol(manaType),
                )),
          ],
        ),
      ),
    );
  }
}

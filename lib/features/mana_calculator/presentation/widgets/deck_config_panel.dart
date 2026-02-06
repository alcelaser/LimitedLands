import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mtg_constants.dart';
import '../providers/mana_calculator_provider.dart';

class DeckConfigPanel extends ConsumerWidget {
  const DeckConfigPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manaCalculatorProvider);
    final notifier = ref.read(manaCalculatorProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deck Configuration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Format presets
            Wrap(
              spacing: 8,
              children: MtgConstants.formatPresets.entries.map((preset) {
                final isSelected =
                    state.input.deckSize == preset.value['deckSize'] &&
                        state.input.totalLands == preset.value['landCount'];
                return FilterChip(
                  label: Text(preset.key),
                  selected: isSelected,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    notifier.applyFormatPreset(preset.key);
                  },
                  selectedColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Deck size row
            _ConfigRow(
              label: 'Deck Size',
              value: state.input.deckSize,
              onIncrement: () =>
                  notifier.updateDeckSize(state.input.deckSize + 1),
              onDecrement: () =>
                  notifier.updateDeckSize(state.input.deckSize - 1),
            ),
            const SizedBox(height: 8),
            // Total lands row
            _ConfigRow(
              label: 'Total Lands',
              value: state.input.totalLands,
              onIncrement: () =>
                  notifier.updateTotalLands(state.input.totalLands + 1),
              onDecrement: () =>
                  notifier.updateTotalLands(state.input.totalLands - 1),
            ),
            const SizedBox(height: 8),
            // Non-land slots info
            Text(
              'Non-land slots: ${state.input.deckSize - state.input.totalLands}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
            ),
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _SmallStepperButton(
          icon: Icons.remove,
          onTap: () {
            HapticFeedback.lightImpact();
            onDecrement();
          },
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        _SmallStepperButton(
          icon: Icons.add,
          onTap: () {
            HapticFeedback.lightImpact();
            onIncrement();
          },
        ),
      ],
    );
  }
}

class _SmallStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallStepperButton({required this.icon, required this.onTap});

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
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/mana_symbol_widget.dart';
import '../../../../core/constants/mtg_constants.dart';

class ManaInputRow extends StatelessWidget {
  final String manaType;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ManaInputRow({
    super.key,
    required this.manaType,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colorName = MtgConstants.manaNames[manaType] ?? manaType;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ManaSymbolWidget(manaType: manaType, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              colorName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepperButton(
            icon: Icons.remove,
            onTap: count > 0 ? onDecrement : null,
          ),
          SizedBox(
            width: 48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                '$count',
                key: ValueKey(count),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: onTap != null
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.white12,
            ),
          ),
          child: Icon(
            icon,
            color: onTap != null
                ? Theme.of(context).colorScheme.primary
                : Colors.white24,
            size: 20,
          ),
        ),
      ),
    );
  }
}

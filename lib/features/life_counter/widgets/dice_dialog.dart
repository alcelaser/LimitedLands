import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dice_model.dart';
import '../providers/dice_provider.dart';

class DiceDialog extends ConsumerStatefulWidget {
  const DiceDialog({super.key});

  @override
  ConsumerState<DiceDialog> createState() => _DiceDialogState();
}

class _DiceDialogState extends ConsumerState<DiceDialog>
    with SingleTickerProviderStateMixin {
  bool _isRolling = false;
  int? _displayResult;
  List<int>? _batchResults;
  bool? _coinResult;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _roll() async {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
      _coinResult = null;
      _batchResults = null;
    });
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final diceState = ref.read(diceProvider);
    if (diceState.batchCount > 1) {
      final results = ref.read(diceProvider.notifier).batchRoll();
      setState(() {
        _batchResults = results;
        _displayResult = null;
        _isRolling = false;
      });
    } else {
      final result = ref.read(diceProvider.notifier).rollDie();
      setState(() {
        _displayResult = result;
        _batchResults = null;
        _isRolling = false;
      });
    }
    HapticFeedback.lightImpact();
  }

  void _flipCoin() async {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
      _displayResult = null;
      _batchResults = null;
    });
    HapticFeedback.mediumImpact();
    _shakeController.forward(from: 0);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final result = ref.read(diceProvider.notifier).flipCoin();
    setState(() {
      _coinResult = result;
      _isRolling = false;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final diceState = ref.watch(diceProvider);

    return AlertDialog(
      title: const Text('Dice & Coin'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Die type selector
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final die in DieType.values)
                  ChoiceChip(
                    label: Text(die.displayName),
                    selected: diceState.selectedDie == die,
                    onSelected: (_) {
                      HapticFeedback.lightImpact();
                      ref.read(diceProvider.notifier).setSelectedDie(die);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Batch count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Roll count: '),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: diceState.batchCount > 1
                      ? () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(diceProvider.notifier)
                              .setBatchCount(diceState.batchCount - 1);
                        }
                      : null,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  '${diceState.batchCount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: diceState.batchCount < 20
                      ? () {
                          HapticFeedback.lightImpact();
                          ref
                              .read(diceProvider.notifier)
                              .setBatchCount(diceState.batchCount + 1);
                        }
                      : null,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Result display
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset = _isRolling
                    ? ((_shakeController.value * 10) % 2 == 0 ? 3.0 : -3.0)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: _buildResultDisplay(),
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isRolling ? null : _roll,
                    icon: const Icon(Icons.casino),
                    label: const Text('Roll'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRolling ? null : _flipCoin,
                    icon: const Icon(Icons.monetization_on),
                    label: const Text('Flip'),
                  ),
                ),
              ],
            ),
            // Roll history
            if (diceState.rollHistory.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  reverse: true,
                  itemCount: diceState.rollHistory.length,
                  itemBuilder: (context, index) {
                    final roll = diceState.rollHistory[
                        diceState.rollHistory.length - 1 - index];
                    final isMax = roll.result == roll.type.maxValue;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              roll.type.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Text(
                            '${roll.result}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMax
                                  ? Colors.amber.shade300
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (diceState.rollHistory.isNotEmpty)
          TextButton(
            onPressed: () {
              ref.read(diceProvider.notifier).clearHistory();
            },
            child: const Text('Clear'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    if (_isRolling) {
      return const Center(
        child: Text(
          '...',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (_coinResult != null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.monetization_on,
              size: 32,
              color: _coinResult! ? Colors.amber.shade300 : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              _coinResult! ? 'HEADS' : 'TAILS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _coinResult! ? Colors.amber.shade300 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_batchResults != null && _batchResults!.isNotEmpty) {
      final sum = _batchResults!.reduce((a, b) => a + b);
      return Center(
        child: Column(
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final r in _batchResults!)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$r',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (_batchResults!.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                'Total: $sum',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_displayResult != null) {
      return Center(
        child: Text(
          '$_displayResult',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Center(
      child: Text(
        'Tap Roll or Flip',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

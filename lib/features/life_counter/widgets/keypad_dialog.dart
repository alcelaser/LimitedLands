import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeypadDialog extends StatefulWidget {
  final int currentValue;
  final String playerName;

  const KeypadDialog({
    super.key,
    required this.currentValue,
    required this.playerName,
  });

  @override
  State<KeypadDialog> createState() => _KeypadDialogState();
}

class _KeypadDialogState extends State<KeypadDialog> {
  String _input = '';

  int get _displayValue =>
      _input.isEmpty ? widget.currentValue : (int.tryParse(_input) ?? 0);

  void _appendDigit(String digit) {
    if (_input.length >= 4) return; // max 9999
    setState(() => _input += digit);
    HapticFeedback.lightImpact();
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
    HapticFeedback.lightImpact();
  }

  void _clear() {
    setState(() => _input = '');
    HapticFeedback.lightImpact();
  }

  void _confirm() {
    if (_input.isNotEmpty) {
      Navigator.of(context).pop(int.tryParse(_input));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.playerName} Life'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '$_displayValue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _input.isEmpty ? Colors.white38 : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Keypad
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['C', '0', '\u232B'],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _KeypadButton(
                          label: key,
                          onTap: () {
                            if (key == 'C') {
                              _clear();
                            } else if (key == '\u232B') {
                              _backspace();
                            } else {
                              _appendDigit(key);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Set'),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

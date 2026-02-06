import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mana_calculator_provider.dart';
import '../widgets/mana_input_panel.dart';
import '../widgets/deck_config_panel.dart';
import '../widgets/land_output_panel.dart';

class ManaCalculatorScreen extends ConsumerWidget {
  const ManaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mana Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(manaCalculatorProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            DeckConfigPanel(),
            SizedBox(height: 12),
            ManaInputPanel(),
            SizedBox(height: 12),
            LandOutputPanel(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

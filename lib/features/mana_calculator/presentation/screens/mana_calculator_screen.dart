import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mana_calculator_provider.dart';
import '../widgets/mana_input_panel.dart';
import '../widgets/deck_config_panel.dart';
import '../widgets/land_output_panel.dart';
import 'cube_calculator_screen.dart';

class ManaCalculatorScreen extends StatelessWidget {
  const ManaCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mana Calculator'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Limited'),
              Tab(text: 'Vintage Cube'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LimitedTab(),
            CubeCalculatorScreen(),
          ],
        ),
      ),
    );
  }
}

class _LimitedTab extends ConsumerWidget {
  const _LimitedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const SingleChildScrollView(
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
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'limited_reset',
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(manaCalculatorProvider.notifier).reset();
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}

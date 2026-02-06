import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../../features/mana_calculator/presentation/screens/mana_calculator_screen.dart';
import '../../features/life_counter/screens/life_counter_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/${RouteNames.calculator}',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/${RouteNames.calculator}',
            name: RouteNames.calculator,
            builder: (context, state) => const ManaCalculatorScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.matchTracker}',
            name: RouteNames.matchTracker,
            builder: (context, state) => const _ComingSoonScreen(title: 'Match Tracker'),
          ),
          GoRoute(
            path: '/${RouteNames.deckBuilder}',
            name: RouteNames.deckBuilder,
            builder: (context, state) => const _ComingSoonScreen(title: 'Deck Builder'),
          ),
          GoRoute(
            path: '/${RouteNames.lifeCounter}',
            name: RouteNames.lifeCounter,
            builder: (context, state) => const LifeCounterScreen(),
          ),
        ],
      ),
    ],
  );
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }
}

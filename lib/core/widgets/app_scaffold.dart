import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/${RouteNames.calculator}')) return 0;
    if (location.startsWith('/${RouteNames.matchTracker}')) return 1;
    if (location.startsWith('/${RouteNames.deckBuilder}')) return 2;
    if (location.startsWith('/${RouteNames.lifeCounter}')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed(RouteNames.calculator);
            case 1:
              context.goNamed(RouteNames.matchTracker);
            case 2:
              context.goNamed(RouteNames.deckBuilder);
            case 3:
              context.goNamed(RouteNames.lifeCounter);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Mana',
          ),
          NavigationDestination(
            icon: Icon(Icons.scoreboard_outlined),
            selectedIcon: Icon(Icons.scoreboard),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'Decks',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Life',
          ),
        ],
      ),
    );
  }
}

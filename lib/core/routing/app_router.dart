import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../../features/mana_calculator/presentation/screens/mana_calculator_screen.dart';
import '../../features/life_counter/screens/game_setup_screen.dart';
import '../../features/life_counter/screens/life_counter_game_screen.dart';
import '../../features/deck_builder/screens/deck_list_screen.dart';
import '../../features/match_tracker/screens/events_home_screen.dart';
import '../../features/card_search/screens/card_search_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/${RouteNames.calculator}',
    routes: [
      // Full-screen game route (outside ShellRoute, no bottom nav)
      GoRoute(
        path: '/game',
        name: RouteNames.lifeCounterGame,
        builder: (context, state) => const LifeCounterGameScreen(),
      ),
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
            builder: (context, state) => const EventsHomeScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.deckBuilder}',
            name: RouteNames.deckBuilder,
            builder: (context, state) => const DeckListScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.lifeCounter}',
            name: RouteNames.lifeCounter,
            builder: (context, state) => const GameSetupScreen(),
          ),
          GoRoute(
            path: '/${RouteNames.cardSearch}',
            name: RouteNames.cardSearch,
            builder: (context, state) => const CardSearchScreen(),
          ),
        ],
      ),
    ],
  );
}

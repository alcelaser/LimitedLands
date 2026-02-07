import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/life_counter/models/game_state_model.dart';
import 'package:limited_lands/features/life_counter/providers/game_setup_provider.dart';

void main() {
  late GameSetupNotifier notifier;

  setUp(() {
    notifier = GameSetupNotifier();
  });

  group('GameSetupNotifier', () {
    group('initial state', () {
      test('has default values', () {
        expect(notifier.state.playerCount, 2);
        expect(notifier.state.startingLife, 20);
        expect(notifier.state.format, GameFormat.standard);
        expect(notifier.state.planechaseEnabled, isFalse);
        expect(notifier.state.partnerEnabled, isFalse);
      });
    });

    group('setPlayerCount', () {
      test('sets valid count', () {
        notifier.setPlayerCount(4);

        expect(notifier.state.playerCount, 4);
      });

      test('clamps to minimum 2', () {
        notifier.setPlayerCount(1);

        expect(notifier.state.playerCount, 2);
      });

      test('clamps to maximum 10', () {
        notifier.setPlayerCount(15);

        expect(notifier.state.playerCount, 10);
      });
    });

    group('setStartingLife', () {
      test('sets valid life', () {
        notifier.setStartingLife(40);

        expect(notifier.state.startingLife, 40);
      });

      test('ignores less than 1', () {
        notifier.setStartingLife(0);

        expect(notifier.state.startingLife, 20);
      });

      test('allows custom values', () {
        notifier.setStartingLife(100);

        expect(notifier.state.startingLife, 100);
      });
    });

    group('setFormat', () {
      test('standard sets life to 20 and disables partner', () {
        notifier.setFormat(GameFormat.commander);
        notifier.togglePartner();
        expect(notifier.state.partnerEnabled, isTrue);

        notifier.setFormat(GameFormat.standard);

        expect(notifier.state.format, GameFormat.standard);
        expect(notifier.state.startingLife, 20);
        expect(notifier.state.partnerEnabled, isFalse);
      });

      test('commander sets life to 40', () {
        notifier.setFormat(GameFormat.commander);

        expect(notifier.state.format, GameFormat.commander);
        expect(notifier.state.startingLife, 40);
      });

      test('custom preserves current life', () {
        notifier.setStartingLife(30);
        notifier.setFormat(GameFormat.custom);

        expect(notifier.state.format, GameFormat.custom);
        expect(notifier.state.startingLife, 30);
      });
    });

    group('togglePlanechase', () {
      test('toggles planechase enabled', () {
        expect(notifier.state.planechaseEnabled, isFalse);

        notifier.togglePlanechase();
        expect(notifier.state.planechaseEnabled, isTrue);

        notifier.togglePlanechase();
        expect(notifier.state.planechaseEnabled, isFalse);
      });
    });

    group('togglePartner', () {
      test('toggles partner enabled', () {
        expect(notifier.state.partnerEnabled, isFalse);

        notifier.togglePartner();
        expect(notifier.state.partnerEnabled, isTrue);

        notifier.togglePartner();
        expect(notifier.state.partnerEnabled, isFalse);
      });
    });

    group('reset', () {
      test('restores default config', () {
        notifier.setPlayerCount(6);
        notifier.setFormat(GameFormat.commander);
        notifier.togglePlanechase();
        notifier.togglePartner();

        notifier.reset();

        expect(notifier.state.playerCount, 2);
        expect(notifier.state.startingLife, 20);
        expect(notifier.state.format, GameFormat.standard);
        expect(notifier.state.planechaseEnabled, isFalse);
        expect(notifier.state.partnerEnabled, isFalse);
      });
    });
  });
}

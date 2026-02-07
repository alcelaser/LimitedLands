import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/life_counter/providers/life_counter_provider.dart';

void main() {
  late LifeCounterNotifier notifier;

  setUp(() {
    notifier = LifeCounterNotifier();
  });

  group('LifeCounterNotifier', () {
    group('initial state', () {
      test('both players have 20 life, 0 poison, 0 experience, empty history',
          () {
        expect(notifier.state.player1.life, 20);
        expect(notifier.state.player2.life, 20);
        expect(notifier.state.player1.poison, 0);
        expect(notifier.state.player2.poison, 0);
        expect(notifier.state.player1.experience, 0);
        expect(notifier.state.player2.experience, 0);
        expect(notifier.state.player1.history, isEmpty);
        expect(notifier.state.player2.history, isEmpty);
        expect(notifier.state.startingLife, 20);
      });
    });

    group('changeLife', () {
      test('player 1 adds delta to life', () {
        notifier.changeLife(1, 3);

        expect(notifier.state.player1.life, 23);
        expect(notifier.state.player2.life, 20);
      });

      test('player 2 adds delta to life', () {
        notifier.changeLife(2, 5);

        expect(notifier.state.player2.life, 25);
        expect(notifier.state.player1.life, 20);
      });

      test('appends to history', () {
        notifier.changeLife(1, 3);
        notifier.changeLife(1, -2);
        notifier.changeLife(1, 5);

        expect(notifier.state.player1.history, [3, -2, 5]);
        expect(notifier.state.player1.life, 26);
      });

      test('with negative delta (damage)', () {
        notifier.changeLife(1, -7);

        expect(notifier.state.player1.life, 13);
        expect(notifier.state.player1.history, [-7]);
      });
    });

    group('changePoison', () {
      test('increments poison', () {
        notifier.changePoison(1, 3);

        expect(notifier.state.player1.poison, 3);
      });

      test('clamped at 10', () {
        notifier.changePoison(1, 8);
        notifier.changePoison(1, 5);

        expect(notifier.state.player1.poison, 10);
      });

      test('clamped at 0', () {
        notifier.changePoison(1, 2);
        notifier.changePoison(1, -5);

        expect(notifier.state.player1.poison, 0);
      });
    });

    group('changeExperience', () {
      test('increments experience', () {
        notifier.changeExperience(2, 4);

        expect(notifier.state.player2.experience, 4);
      });

      test('clamped at 999', () {
        notifier.changeExperience(1, 500);
        notifier.changeExperience(1, 500);
        notifier.changeExperience(1, 500);

        expect(notifier.state.player1.experience, 999);
      });

      test('clamped at 0', () {
        notifier.changeExperience(1, 3);
        notifier.changeExperience(1, -10);

        expect(notifier.state.player1.experience, 0);
      });
    });

    group('reset', () {
      test('restores starting state and clears history', () {
        notifier.changeLife(1, -5);
        notifier.changeLife(2, 10);
        notifier.changePoison(1, 3);
        notifier.changeExperience(2, 7);

        notifier.reset();

        expect(notifier.state.player1.life, 20);
        expect(notifier.state.player2.life, 20);
        expect(notifier.state.player1.poison, 0);
        expect(notifier.state.player2.poison, 0);
        expect(notifier.state.player1.experience, 0);
        expect(notifier.state.player2.experience, 0);
        expect(notifier.state.player1.history, isEmpty);
        expect(notifier.state.player2.history, isEmpty);
      });
    });

    group('history cap', () {
      test('capped at 100 entries', () {
        // Add 105 entries; only the last 100 should remain.
        for (int i = 1; i <= 105; i++) {
          notifier.changeLife(1, 1);
        }

        expect(notifier.state.player1.history.length, 100);
        // Life should still reflect all 105 increments.
        expect(notifier.state.player1.life, 20 + 105);
        // The first entry retained should be the 6th delta (the first 5 were trimmed).
        // All deltas are 1, so every entry is 1.
        expect(notifier.state.player1.history.every((d) => d == 1), isTrue);
      });
    });
  });
}

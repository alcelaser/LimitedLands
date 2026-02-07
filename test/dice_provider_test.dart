import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/life_counter/models/dice_model.dart';
import 'package:limited_lands/features/life_counter/providers/dice_provider.dart';

void main() {
  group('DiceNotifier', () {
    late DiceNotifier notifier;

    setUp(() {
      notifier = DiceNotifier();
    });

    test('initial state', () {
      expect(notifier.state.selectedDie, DieType.d20);
      expect(notifier.state.batchCount, 1);
      expect(notifier.state.rollHistory, isEmpty);
      expect(notifier.state.lastBatchResults, isEmpty);
    });

    test('setSelectedDie changes die type', () {
      notifier.setSelectedDie(DieType.d6);
      expect(notifier.state.selectedDie, DieType.d6);
    });

    test('setBatchCount clamps to 1-20', () {
      notifier.setBatchCount(5);
      expect(notifier.state.batchCount, 5);

      notifier.setBatchCount(0);
      expect(notifier.state.batchCount, 1);

      notifier.setBatchCount(25);
      expect(notifier.state.batchCount, 20);
    });

    test('rollDie returns value in range', () {
      for (final die in DieType.values) {
        for (int i = 0; i < 20; i++) {
          final result = notifier.rollDie(die);
          expect(result, greaterThanOrEqualTo(1));
          expect(result, lessThanOrEqualTo(die.maxValue));
        }
      }
    });

    test('rollDie adds to history', () {
      notifier.rollDie();
      expect(notifier.state.rollHistory.length, 1);
      expect(notifier.state.lastBatchResults.length, 1);
    });

    test('batchRoll returns correct count', () {
      notifier.setBatchCount(5);
      final results = notifier.batchRoll(DieType.d6);
      expect(results.length, 5);
      for (final r in results) {
        expect(r, greaterThanOrEqualTo(1));
        expect(r, lessThanOrEqualTo(6));
      }
    });

    test('batchRoll adds all to history', () {
      notifier.setBatchCount(3);
      notifier.batchRoll();
      expect(notifier.state.rollHistory.length, 3);
      expect(notifier.state.lastBatchResults.length, 3);
    });

    test('history capped at 50', () {
      for (int i = 0; i < 60; i++) {
        notifier.rollDie();
      }
      expect(notifier.state.rollHistory.length, 50);
    });

    test('flipCoin returns bool', () {
      final result = notifier.flipCoin();
      expect(result, isA<bool>());
    });

    test('clearHistory empties state', () {
      notifier.rollDie();
      notifier.clearHistory();
      expect(notifier.state.rollHistory, isEmpty);
      expect(notifier.state.lastBatchResults, isEmpty);
    });
  });

  group('HighRollNotifier', () {
    late HighRollNotifier notifier;

    setUp(() {
      notifier = HighRollNotifier();
    });

    test('initialize creates slots for all players', () {
      notifier.initialize(4);
      expect(notifier.state.playerRolls.length, 4);
      for (final roll in notifier.state.playerRolls.values) {
        expect(roll, isNull);
      }
      expect(notifier.state.isComplete, false);
      expect(notifier.state.winnerIndex, isNull);
    });

    test('rollForPlayer sets a roll value', () {
      notifier.initialize(2);
      notifier.rollForPlayer(0);
      expect(notifier.state.playerRolls[0], isNotNull);
      expect(notifier.state.playerRolls[0], greaterThanOrEqualTo(1));
      expect(notifier.state.playerRolls[0], lessThanOrEqualTo(20));
    });

    test('rollForPlayer ignores already-rolled player', () {
      notifier.initialize(2);
      notifier.rollForPlayer(0);
      final first = notifier.state.playerRolls[0];
      notifier.rollForPlayer(0);
      expect(notifier.state.playerRolls[0], first);
    });

    test('rollAll sets all rolls', () {
      notifier.initialize(4);
      notifier.rollAll();
      for (final roll in notifier.state.playerRolls.values) {
        expect(roll, isNotNull);
        expect(roll, greaterThanOrEqualTo(1));
        expect(roll, lessThanOrEqualTo(20));
      }
    });

    test('reset clears all rolls', () {
      notifier.initialize(3);
      notifier.rollAll();
      notifier.reset();
      for (final roll in notifier.state.playerRolls.values) {
        expect(roll, isNull);
      }
      expect(notifier.state.isComplete, false);
      expect(notifier.state.winnerIndex, isNull);
    });
  });

  group('DieType extension', () {
    test('maxValue correct', () {
      expect(DieType.d4.maxValue, 4);
      expect(DieType.d6.maxValue, 6);
      expect(DieType.d8.maxValue, 8);
      expect(DieType.d10.maxValue, 10);
      expect(DieType.d12.maxValue, 12);
      expect(DieType.d20.maxValue, 20);
    });

    test('displayName correct', () {
      expect(DieType.d4.displayName, 'D4');
      expect(DieType.d20.displayName, 'D20');
    });
  });
}

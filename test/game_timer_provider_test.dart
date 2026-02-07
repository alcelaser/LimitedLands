import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/life_counter/providers/game_timer_provider.dart';

void main() {
  group('GameTimerNotifier', () {
    late GameTimerNotifier notifier;

    setUp(() {
      notifier = GameTimerNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state', () {
      expect(notifier.state.elapsed, Duration.zero);
      expect(notifier.state.isRunning, false);
      expect(notifier.state.playerTurnTimes, isEmpty);
      expect(notifier.state.currentPlayerIndex, isNull);
    });

    test('start sets isRunning and currentPlayerIndex', () {
      notifier.start(0);
      expect(notifier.state.isRunning, true);
      expect(notifier.state.currentPlayerIndex, 0);
    });

    test('start is idempotent when already running', () {
      notifier.start(0);
      notifier.start(1);
      expect(notifier.state.currentPlayerIndex, 0);
    });

    test('pause stops running', () {
      notifier.start(0);
      notifier.pause();
      expect(notifier.state.isRunning, false);
    });

    test('resume restarts running', () {
      notifier.start(0);
      notifier.pause();
      notifier.resume();
      expect(notifier.state.isRunning, true);
    });

    test('resume is idempotent when already running', () {
      notifier.start(0);
      notifier.resume();
      expect(notifier.state.isRunning, true);
    });

    test('switchTurn changes currentPlayerIndex', () {
      notifier.start(0);
      notifier.switchTurn(1);
      expect(notifier.state.currentPlayerIndex, 1);
    });

    test('reset clears all state', () {
      notifier.start(0);
      notifier.reset();
      expect(notifier.state.elapsed, Duration.zero);
      expect(notifier.state.isRunning, false);
      expect(notifier.state.playerTurnTimes, isEmpty);
      expect(notifier.state.currentPlayerIndex, isNull);
    });
  });

  group('GameTimerState', () {
    test('formattedElapsed with zero', () {
      const state = GameTimerState();
      expect(state.formattedElapsed, '00:00');
    });

    test('formattedElapsed with minutes and seconds', () {
      const state = GameTimerState(
        elapsed: Duration(minutes: 5, seconds: 30),
      );
      expect(state.formattedElapsed, '05:30');
    });

    test('formattedElapsed with hours', () {
      const state = GameTimerState(
        elapsed: Duration(hours: 1, minutes: 23, seconds: 45),
      );
      expect(state.formattedElapsed, '1:23:45');
    });

    test('formattedPlayerTime returns zero for missing player', () {
      const state = GameTimerState();
      expect(state.formattedPlayerTime(0), '00:00');
    });

    test('formattedPlayerTime returns tracked time', () {
      const state = GameTimerState(
        playerTurnTimes: {0: Duration(minutes: 3, seconds: 15)},
      );
      expect(state.formattedPlayerTime(0), '03:15');
    });

    test('copyWith preserves values', () {
      const state = GameTimerState(
        elapsed: Duration(minutes: 5),
        isRunning: true,
        currentPlayerIndex: 2,
      );
      final copy = state.copyWith(isRunning: false);
      expect(copy.elapsed, const Duration(minutes: 5));
      expect(copy.isRunning, false);
      expect(copy.currentPlayerIndex, 2);
    });

    test('copyWith clearCurrentPlayer', () {
      const state = GameTimerState(currentPlayerIndex: 1);
      final copy = state.copyWith(clearCurrentPlayer: true);
      expect(copy.currentPlayerIndex, isNull);
    });
  });
}

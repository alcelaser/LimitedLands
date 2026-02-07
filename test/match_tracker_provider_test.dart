import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limited_lands/features/match_tracker/providers/match_tracker_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<MatchTrackerNotifier> createNotifier() async {
    final notifier = MatchTrackerNotifier();
    // Allow the async _loadFromStorage to complete.
    await Future.delayed(Duration.zero);
    return notifier;
  }

  group('MatchTrackerNotifier', () {
    group('createEvent', () {
      test('adds event with correct defaults', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();

        expect(notifier.state.events.length, 1);
        expect(event.name, 'New Event');
        expect(event.format, 'Limited');
        expect(event.matches, isEmpty);
        expect(event.id, 'event_1');
      });

      test('puts newest first', () async {
        final notifier = await createNotifier();
        notifier.createEvent(name: 'First');
        notifier.createEvent(name: 'Second');
        notifier.createEvent(name: 'Third');

        expect(notifier.state.events.length, 3);
        expect(notifier.state.events[0].name, 'Third');
        expect(notifier.state.events[1].name, 'Second');
        expect(notifier.state.events[2].name, 'First');
      });

      test('generates unique IDs', () async {
        final notifier = await createNotifier();
        final e1 = notifier.createEvent(name: 'A');
        final e2 = notifier.createEvent(name: 'B');
        final e3 = notifier.createEvent(name: 'C');

        expect(e1.id, 'event_1');
        expect(e2.id, 'event_2');
        expect(e3.id, 'event_3');
      });
    });

    group('deleteEvent', () {
      test('removes correct event', () async {
        final notifier = await createNotifier();
        notifier.createEvent(name: 'Keep');
        final e2 = notifier.createEvent(name: 'Remove');
        notifier.createEvent(name: 'Also Keep');

        notifier.deleteEvent(e2.id);

        expect(notifier.state.events.length, 2);
        final names = notifier.state.events.map((e) => e.name).toList();
        expect(names, contains('Keep'));
        expect(names, contains('Also Keep'));
        expect(names, isNot(contains('Remove')));
      });
    });

    group('addMatch', () {
      test('creates match with incrementing round numbers', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();

        final m1 = notifier.addMatch(event.id);
        final m2 = notifier.addMatch(event.id);
        final m3 = notifier.addMatch(event.id);

        expect(m1, isNotNull);
        expect(m2, isNotNull);
        expect(m3, isNotNull);
        expect(m1!.roundNumber, 1);
        expect(m2!.roundNumber, 2);
        expect(m3!.roundNumber, 3);

        final updated = notifier.state.events.first;
        expect(updated.matches.length, 3);
      });

      test('returns null for unknown eventId', () async {
        final notifier = await createNotifier();

        final result = notifier.addMatch('nonexistent');

        expect(result, isNull);
      });
    });

    group('recordGameWin', () {
      test('increments gamesWon', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.recordGameWin(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.gamesWon, 1);
        expect(updated.gamesLost, 0);
      });

      test('is no-op after match complete (2 wins)', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.recordGameWin(event.id, match.id);
        notifier.recordGameWin(event.id, match.id);

        // Match is now complete (2 wins). Further wins should be ignored.
        notifier.recordGameWin(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.gamesWon, 2);
        expect(updated.isComplete, isTrue);
        expect(updated.result, MatchResult.win);
      });
    });

    group('recordGameLoss', () {
      test('increments gamesLost', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.recordGameLoss(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.gamesLost, 1);
        expect(updated.gamesWon, 0);
      });

      test('is no-op after match complete (2 losses)', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.recordGameLoss(event.id, match.id);
        notifier.recordGameLoss(event.id, match.id);

        // Match is now complete (2 losses). Further losses should be ignored.
        notifier.recordGameLoss(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.gamesLost, 2);
        expect(updated.isComplete, isTrue);
        expect(updated.result, MatchResult.loss);
      });
    });

    group('toggleDraw', () {
      test('sets isDraw and resets game counts', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        // Record some games first.
        notifier.recordGameWin(event.id, match.id);
        notifier.recordGameLoss(event.id, match.id);

        notifier.toggleDraw(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.isDraw, isTrue);
        expect(updated.gamesWon, 0);
        expect(updated.gamesLost, 0);
        expect(updated.result, MatchResult.draw);
      });

      test('again unsets isDraw', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.toggleDraw(event.id, match.id);
        expect(notifier.state.events.first.matches.first.isDraw, isTrue);

        notifier.toggleDraw(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.isDraw, isFalse);
        expect(updated.gamesWon, 0);
        expect(updated.gamesLost, 0);
        expect(updated.result, MatchResult.inProgress);
      });
    });

    group('resetMatch', () {
      test('clears all fields', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();
        final match = notifier.addMatch(event.id)!;

        notifier.recordGameWin(event.id, match.id);
        notifier.recordGameWin(event.id, match.id);

        notifier.resetMatch(event.id, match.id);

        final updated = notifier.state.events.first.matches.first;
        expect(updated.gamesWon, 0);
        expect(updated.gamesLost, 0);
        expect(updated.isDraw, isFalse);
        expect(updated.result, MatchResult.inProgress);
      });
    });

    group('removeMatch', () {
      test('renumbers remaining rounds', () async {
        final notifier = await createNotifier();
        final event = notifier.createEvent();

        final m1 = notifier.addMatch(event.id)!;
        notifier.addMatch(event.id);
        notifier.addMatch(event.id);

        // Remove the first match (round 1).
        notifier.removeMatch(event.id, m1.id);

        final updated = notifier.state.events.first;
        expect(updated.matches.length, 2);
        expect(updated.matches[0].roundNumber, 1);
        expect(updated.matches[1].roundNumber, 2);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limited_lands/features/match_tracker/models/tournament_models.dart';
import 'package:limited_lands/features/match_tracker/providers/tournament_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<TournamentNotifier> createNotifier() async {
    final notifier = TournamentNotifier();
    await Future.delayed(Duration.zero);
    return notifier;
  }

  group('TournamentNotifier', () {
    group('createTournament', () {
      test('adds tournament with correct defaults', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();

        expect(notifier.state.tournaments.length, 1);
        expect(tournament.name, 'New Tournament');
        expect(tournament.format, 'Limited');
        expect(tournament.totalRounds, 3);
        expect(tournament.status, TournamentStatus.setup);
        expect(tournament.players, isEmpty);
        expect(tournament.rounds, isEmpty);
        expect(tournament.id, 'tourn_1');
      });

      test('puts newest first', () async {
        final notifier = await createNotifier();
        notifier.createTournament(name: 'First');
        notifier.createTournament(name: 'Second');
        notifier.createTournament(name: 'Third');

        expect(notifier.state.tournaments.length, 3);
        expect(notifier.state.tournaments[0].name, 'Third');
        expect(notifier.state.tournaments[1].name, 'Second');
        expect(notifier.state.tournaments[2].name, 'First');
      });

      test('generates unique IDs', () async {
        final notifier = await createNotifier();
        final t1 = notifier.createTournament(name: 'A');
        final t2 = notifier.createTournament(name: 'B');
        final t3 = notifier.createTournament(name: 'C');

        expect(t1.id, 'tourn_1');
        expect(t2.id, 'tourn_2');
        expect(t3.id, 'tourn_3');
      });
    });

    group('deleteTournament', () {
      test('removes correct tournament', () async {
        final notifier = await createNotifier();
        notifier.createTournament(name: 'Keep');
        final t2 = notifier.createTournament(name: 'Remove');
        notifier.createTournament(name: 'Also Keep');

        notifier.deleteTournament(t2.id);

        expect(notifier.state.tournaments.length, 2);
        final names =
            notifier.state.tournaments.map((t) => t.name).toList();
        expect(names, contains('Keep'));
        expect(names, contains('Also Keep'));
        expect(names, isNot(contains('Remove')));
      });
    });

    group('addPlayer', () {
      test('adds player during setup phase', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();

        final player = notifier.addPlayer(tournament.id, 'Alice');

        expect(player, isNotNull);
        expect(player!.name, 'Alice');
        expect(player.id, 'tp_1');
        expect(notifier.state.tournaments.first.players.length, 1);
      });

      test('returns null if tournament in progress', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);

        final player = notifier.addPlayer(tournament.id, 'Carol');

        expect(player, isNull);
        expect(notifier.state.tournaments.first.players.length, 2);
      });

      test('generates unique player IDs', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();

        final p1 = notifier.addPlayer(tournament.id, 'Alice');
        final p2 = notifier.addPlayer(tournament.id, 'Bob');
        final p3 = notifier.addPlayer(tournament.id, 'Carol');

        expect(p1!.id, 'tp_1');
        expect(p2!.id, 'tp_2');
        expect(p3!.id, 'tp_3');
      });
    });

    group('removePlayer', () {
      test('removes player during setup phase', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        final player = notifier.addPlayer(tournament.id, 'Alice')!;
        notifier.addPlayer(tournament.id, 'Bob');

        notifier.removePlayer(tournament.id, player.id);

        expect(notifier.state.tournaments.first.players.length, 1);
        expect(
            notifier.state.tournaments.first.players.first.name, 'Bob');
      });

      test('no-op if tournament in progress', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        final player = notifier.addPlayer(tournament.id, 'Alice')!;
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);

        notifier.removePlayer(tournament.id, player.id);

        expect(notifier.state.tournaments.first.players.length, 2);
      });
    });

    group('startTournament', () {
      test('changes status from setup to inProgress', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');

        notifier.startTournament(tournament.id);

        expect(notifier.state.tournaments.first.status,
            TournamentStatus.inProgress);
      });

      test('no-op if fewer than 2 players', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');

        notifier.startTournament(tournament.id);

        expect(notifier.state.tournaments.first.status,
            TournamentStatus.setup);
      });

      test('no-op if already in progress', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);

        // Try starting again.
        notifier.startTournament(tournament.id);

        // Should still be in progress, not crash.
        expect(notifier.state.tournaments.first.status,
            TournamentStatus.inProgress);
      });
    });

    group('generateNextRound', () {
      test('creates round with correct pairings', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.addPlayer(tournament.id, 'Carol');
        notifier.addPlayer(tournament.id, 'Dave');
        notifier.startTournament(tournament.id);

        notifier.generateNextRound(tournament.id);

        final updated = notifier.state.tournaments.first;
        expect(updated.rounds.length, 1);
        expect(updated.rounds.first.roundNumber, 1);
        expect(updated.rounds.first.pairings.length, 2);
      });

      test('no-op if previous round incomplete', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);
        notifier.generateNextRound(tournament.id);

        // Try generating another round without completing first.
        notifier.generateNextRound(tournament.id);

        expect(notifier.state.tournaments.first.rounds.length, 1);
      });

      test('no-op if all rounds completed', () async {
        final notifier = await createNotifier();
        final tournament =
            notifier.createTournament(totalRounds: 1);
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);

        notifier.generateNextRound(tournament.id);

        // Complete the round.
        final round = notifier.state.tournaments.first.rounds.first;
        notifier.reportResult(
          tournament.id,
          round.roundNumber,
          round.pairings.first.id,
          player1Wins: 2,
          player2Wins: 0,
        );

        // Try generating another round beyond totalRounds.
        notifier.generateNextRound(tournament.id);

        expect(notifier.state.tournaments.first.rounds.length, 1);
      });
    });

    group('reportResult', () {
      test('updates pairing with scores and marks complete', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);
        notifier.generateNextRound(tournament.id);

        final round = notifier.state.tournaments.first.rounds.first;
        notifier.reportResult(
          tournament.id,
          round.roundNumber,
          round.pairings.first.id,
          player1Wins: 2,
          player2Wins: 1,
        );

        final updated = notifier.state.tournaments.first.rounds.first
            .pairings.first;
        expect(updated.player1Wins, 2);
        expect(updated.player2Wins, 1);
        expect(updated.isComplete, isTrue);
        expect(updated.isDraw, isFalse);
      });

      test('draw sets isDraw flag', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);
        notifier.generateNextRound(tournament.id);

        final round = notifier.state.tournaments.first.rounds.first;
        notifier.reportResult(
          tournament.id,
          round.roundNumber,
          round.pairings.first.id,
          player1Wins: 0,
          player2Wins: 0,
          isDraw: true,
        );

        final updated = notifier.state.tournaments.first.rounds.first
            .pairings.first;
        expect(updated.isDraw, isTrue);
        expect(updated.isComplete, isTrue);
      });
    });

    group('resetPairing', () {
      test('clears score and marks incomplete', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);
        notifier.generateNextRound(tournament.id);

        final round = notifier.state.tournaments.first.rounds.first;
        notifier.reportResult(
          tournament.id,
          round.roundNumber,
          round.pairings.first.id,
          player1Wins: 2,
          player2Wins: 1,
        );

        notifier.resetPairing(
          tournament.id,
          round.roundNumber,
          round.pairings.first.id,
        );

        final updated = notifier.state.tournaments.first.rounds.first
            .pairings.first;
        expect(updated.player1Wins, 0);
        expect(updated.player2Wins, 0);
        expect(updated.isDraw, isFalse);
        expect(updated.isComplete, isFalse);
      });
    });

    group('completeTournament', () {
      test('changes status to completed', () async {
        final notifier = await createNotifier();
        final tournament = notifier.createTournament();
        notifier.addPlayer(tournament.id, 'Alice');
        notifier.addPlayer(tournament.id, 'Bob');
        notifier.startTournament(tournament.id);

        notifier.completeTournament(tournament.id);

        expect(notifier.state.tournaments.first.status,
            TournamentStatus.completed);
      });
    });

    group('persistence', () {
      test('saves to and loads from SharedPreferences', () async {
        final notifier1 = await createNotifier();
        final tournament = notifier1.createTournament(name: 'Persisted');
        notifier1.addPlayer(tournament.id, 'Alice');

        // Wait for save to complete.
        await Future.delayed(const Duration(milliseconds: 50));

        // Create a new notifier that loads from the same SharedPreferences.
        final notifier2 = await createNotifier();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(notifier2.state.tournaments.length, 1);
        expect(notifier2.state.tournaments.first.name, 'Persisted');
        expect(
            notifier2.state.tournaments.first.players.length, 1);
      });

      test('recovers sequential IDs after reload', () async {
        final notifier1 = await createNotifier();
        notifier1.createTournament(name: 'T1');
        notifier1.createTournament(name: 'T2');

        await Future.delayed(const Duration(milliseconds: 50));

        final notifier2 = await createNotifier();
        await Future.delayed(const Duration(milliseconds: 50));

        // New tournament should get tourn_3, not tourn_1.
        final t3 = notifier2.createTournament(name: 'T3');
        expect(t3.id, 'tourn_3');
      });
    });
  });
}

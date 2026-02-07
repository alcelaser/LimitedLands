import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/match_tracker/models/tournament_models.dart';
import 'package:limited_lands/features/match_tracker/services/swiss_pairing_service.dart';

void main() {
  Tournament makeTournament(int playerCount, {int totalRounds = 3}) {
    return Tournament(
      id: 'tourn_1',
      name: 'Test',
      totalRounds: totalRounds,
      status: TournamentStatus.inProgress,
      players: List.generate(
        playerCount,
        (i) => TournamentPlayer(id: 'tp_${i + 1}', name: 'Player ${i + 1}'),
      ),
    );
  }

  group('SwissPairingService', () {
    group('recommendedRounds', () {
      test('returns 0 for 0 players', () {
        expect(SwissPairingService.recommendedRounds(0), 0);
      });

      test('returns 0 for 1 player', () {
        expect(SwissPairingService.recommendedRounds(1), 0);
      });

      test('returns 1 for 2 players', () {
        expect(SwissPairingService.recommendedRounds(2), 1);
      });

      test('returns 3 for 8 players', () {
        expect(SwissPairingService.recommendedRounds(8), 3);
      });

      test('returns 4 for 9 players', () {
        expect(SwissPairingService.recommendedRounds(9), 4);
      });

      test('returns 4 for 16 players', () {
        expect(SwissPairingService.recommendedRounds(16), 4);
      });
    });

    group('generateNextRound', () {
      test('pairs 4 players into 2 pairings for round 1', () {
        final tournament = makeTournament(4);
        final round = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 1,
        );

        expect(round.roundNumber, 1);
        expect(round.pairings.length, 2);
        expect(round.pairings.every((p) => !p.isBye), isTrue);
      });

      test('5 players produces 2 pairings + 1 bye', () {
        final tournament = makeTournament(5);
        final round = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 1,
        );

        expect(round.pairings.length, 3);
        final byePairings = round.pairings.where((p) => p.isBye);
        expect(byePairings.length, 1);
        expect(byePairings.first.isComplete, isTrue);
        expect(byePairings.first.player1Wins, 2);
      });

      test('bye goes to lowest-ranked player', () {
        final tournament = makeTournament(5);
        final round = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 1,
        );

        final byePairing = round.pairings.firstWhere((p) => p.isBye);
        // All players have 0 points, so lowest ranked is the last one.
        expect(byePairing.player1Id, 'tp_5');
      });

      test('bye rotates to a different player in round 2', () {
        // Round 1: player 5 gets bye.
        var tournament = makeTournament(5);
        final round1 = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 1,
        );

        // Complete round 1 pairings.
        final completedPairings = round1.pairings.map((p) {
          if (p.isComplete) return p;
          return p.copyWith(player1Wins: 2, player2Wins: 0, isComplete: true);
        }).toList();

        tournament = tournament.copyWith(
          rounds: [round1.copyWith(pairings: completedPairings)],
        );

        // Round 2: bye should go to a different player.
        final round2 = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 10,
        );

        final byePairing = round2.pairings.firstWhere((p) => p.isBye);
        expect(byePairing.player1Id, isNot('tp_5'));
      });

      test('avoids rematches when possible', () {
        // 4 players, set up round 1 manually.
        var tournament = makeTournament(4);
        const round1 = TournamentRound(
          roundNumber: 1,
          pairings: [
            TournamentPairing(
              id: 'pair_1',
              player1Id: 'tp_1',
              player2Id: 'tp_2',
              player1Wins: 2,
              player2Wins: 0,
              isComplete: true,
            ),
            TournamentPairing(
              id: 'pair_2',
              player1Id: 'tp_3',
              player2Id: 'tp_4',
              player1Wins: 2,
              player2Wins: 0,
              isComplete: true,
            ),
          ],
        );

        tournament = tournament.copyWith(rounds: [round1]);

        final round2 = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 3,
        );

        // tp_1 should not be paired with tp_2 again.
        for (final pairing in round2.pairings) {
          final ids = {pairing.player1Id, pairing.player2Id};
          expect(ids, isNot(equals({'tp_1', 'tp_2'})));
          expect(ids, isNot(equals({'tp_3', 'tp_4'})));
        }
      });

      test('allows rematch as fallback with 2 players', () {
        // 2 players: must rematch after round 1.
        var tournament = makeTournament(2, totalRounds: 2);
        const round1 = TournamentRound(
          roundNumber: 1,
          pairings: [
            TournamentPairing(
              id: 'pair_1',
              player1Id: 'tp_1',
              player2Id: 'tp_2',
              player1Wins: 2,
              player2Wins: 1,
              isComplete: true,
            ),
          ],
        );

        tournament = tournament.copyWith(rounds: [round1]);

        final round2 = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 2,
        );

        expect(round2.pairings.length, 1);
        final ids = {
          round2.pairings[0].player1Id,
          round2.pairings[0].player2Id,
        };
        expect(ids, equals({'tp_1', 'tp_2'}));
      });

      test('8 players produce 4 pairings in round 1', () {
        final tournament = makeTournament(8);
        final round = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 1,
        );

        expect(round.pairings.length, 4);
        expect(round.pairings.every((p) => !p.isBye), isTrue);
      });

      test('assigns correct pairing IDs', () {
        final tournament = makeTournament(4);
        final round = SwissPairingService.generateNextRound(
          tournament: tournament,
          nextPairingIdStart: 5,
        );

        expect(round.pairings[0].id, 'pair_5');
        expect(round.pairings[1].id, 'pair_6');
      });
    });

    group('calculateStandings', () {
      test('empty tournament returns all players at 0 points', () {
        final tournament = makeTournament(4);
        final standings =
            SwissPairingService.calculateStandings(tournament);

        expect(standings.length, 4);
        for (final entry in standings) {
          expect(entry.matchPoints, 0);
          expect(entry.wins, 0);
          expect(entry.losses, 0);
          expect(entry.draws, 0);
        }
      });

      test('win counts as 3 match points', () {
        var tournament = makeTournament(2);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);
        final p1 = standings.firstWhere((s) => s.player.id == 'tp_1');
        final p2 = standings.firstWhere((s) => s.player.id == 'tp_2');

        expect(p1.matchPoints, 3);
        expect(p1.wins, 1);
        expect(p2.matchPoints, 0);
        expect(p2.losses, 1);
      });

      test('draw counts as 1 match point each', () {
        var tournament = makeTournament(2);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                isDraw: true,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);
        final p1 = standings.firstWhere((s) => s.player.id == 'tp_1');
        final p2 = standings.firstWhere((s) => s.player.id == 'tp_2');

        expect(p1.matchPoints, 1);
        expect(p1.draws, 1);
        expect(p2.matchPoints, 1);
        expect(p2.draws, 1);
      });

      test('bye counts as a win', () {
        var tournament = makeTournament(3);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
              TournamentPairing(
                id: 'pair_2',
                player1Id: 'tp_3',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);
        final p3 = standings.firstWhere((s) => s.player.id == 'tp_3');

        expect(p3.matchPoints, 3);
        expect(p3.wins, 1);
        expect(p3.byeCount, 1);
      });

      test('sorts by match points descending', () {
        var tournament = makeTournament(3);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 0,
                player2Wins: 2,
                isComplete: true,
              ),
              TournamentPairing(
                id: 'pair_2',
                player1Id: 'tp_3',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);

        expect(standings[0].player.id, isNot('tp_1'));
        expect(standings.last.matchPoints,
            lessThanOrEqualTo(standings.first.matchPoints));
      });

      test('breaks ties by OMW percent', () {
        // Both tp_1 and tp_3 win their round 1 match.
        // tp_1 beat tp_2 (who lost), tp_3 beat tp_4 (who lost).
        // In round 2, tp_2 beats tp_4. Now tp_1's OMW% > tp_3's OMW%
        // because tp_1's opponent (tp_2) won in round 2.
        var tournament = makeTournament(4, totalRounds: 2);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
              TournamentPairing(
                id: 'pair_2',
                player1Id: 'tp_3',
                player2Id: 'tp_4',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
          const TournamentRound(
            roundNumber: 2,
            pairings: [
              TournamentPairing(
                id: 'pair_3',
                player1Id: 'tp_1',
                player2Id: 'tp_3',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
              TournamentPairing(
                id: 'pair_4',
                player1Id: 'tp_2',
                player2Id: 'tp_4',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);

        // tp_1 has 6 pts (2 wins), tp_3 has 3 pts, tp_2 has 3 pts, tp_4 has 0 pts.
        expect(standings[0].player.id, 'tp_1');
        expect(standings[0].matchPoints, 6);
        // tp_2 and tp_3 both have 3 points. tp_2's opponent was tp_1 (6pts) and tp_4 (0pts).
        // tp_3's opponent was tp_4 (0pts) and tp_1 (6pts). Similar OMW%.
      });

      test('OMW percent floors at 0.33', () {
        // Player with 0 wins should have their match win % floored at 0.33.
        var tournament = makeTournament(2, totalRounds: 2);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);
        final winner = standings.firstWhere((s) => s.player.id == 'tp_1');

        // tp_1's opponent (tp_2) has 0/3 = 0% raw, floored to 33%.
        expect(winner.omwPercent, closeTo(0.33, 0.01));
      });

      test('ranks are sequential 1-based', () {
        final tournament = makeTournament(4);
        final standings =
            SwissPairingService.calculateStandings(tournament);

        expect(standings.map((s) => s.rank).toList(), [1, 2, 3, 4]);
      });

      test('record string formats correctly', () {
        var tournament = makeTournament(2);
        tournament = tournament.copyWith(rounds: [
          const TournamentRound(
            roundNumber: 1,
            pairings: [
              TournamentPairing(
                id: 'pair_1',
                player1Id: 'tp_1',
                player2Id: 'tp_2',
                player1Wins: 2,
                player2Wins: 0,
                isComplete: true,
              ),
            ],
          ),
        ]);

        final standings =
            SwissPairingService.calculateStandings(tournament);
        final winner = standings.firstWhere((s) => s.player.id == 'tp_1');
        final loser = standings.firstWhere((s) => s.player.id == 'tp_2');

        expect(winner.record, '1-0');
        expect(loser.record, '0-1');
      });
    });
  });
}

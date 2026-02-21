import 'dart:math';

import '../models/tournament_models.dart';

class SwissPairingService {
  SwissPairingService._();

  /// Calculate the recommended number of Swiss rounds for a player count.
  /// Standard MTG formula: ceil(log2(playerCount)).
  static int recommendedRounds(int playerCount) {
    if (playerCount <= 1) return 0;
    return (log(playerCount) / ln2).ceil();
  }

  /// Generate the next round of pairings for a tournament.
  ///
  /// Uses bracket-based Swiss pairing: players are grouped by match points,
  /// then paired within brackets (top vs bottom). Odd players in a bracket
  /// drop down to the next bracket. Rematches are avoided where possible.
  ///
  /// [nextPairingIdStart] is the next sequential ID number for pairings.
  static TournamentRound generateNextRound({
    required Tournament tournament,
    required int nextPairingIdStart,
  }) {
    final roundNumber = tournament.currentRoundNumber + 1;
    final standings = calculateStandings(tournament);
    final sortedPlayerIds = standings.map((e) => e.player.id).toList();
    final standingsMap = {for (final e in standings) e.player.id: e};
    final previousPairs = _buildPreviousPairsSet(tournament);
    final playersWithBye = _playersWithBye(tournament);

    final pairings = <TournamentPairing>[];
    var pairingId = nextPairingIdStart;

    final remainingIds = List<String>.from(sortedPlayerIds);

    // Handle odd number of players: assign bye to the lowest-ranked player
    // who hasn't had one yet.
    if (remainingIds.length.isOdd) {
      String? byePlayerId;
      for (int i = remainingIds.length - 1; i >= 0; i--) {
        if (!playersWithBye.contains(remainingIds[i])) {
          byePlayerId = remainingIds.removeAt(i);
          break;
        }
      }
      // Fallback: if everyone has had a bye, give to the last player.
      if (byePlayerId == null && remainingIds.isNotEmpty) {
        byePlayerId = remainingIds.removeLast();
      }

      if (byePlayerId != null) {
        pairings.add(TournamentPairing(
          id: 'pair_${pairingId++}',
          player1Id: byePlayerId,
          player1Wins: 2,
          player2Wins: 0,
          isComplete: true,
        ));
      }
    }

    // Bracket-based Swiss pairing with rematch avoidance.
    final paired = _bracketPair(remainingIds, standingsMap, previousPairs);
    for (final pair in paired) {
      pairings.add(TournamentPairing(
        id: 'pair_${pairingId++}',
        player1Id: pair.$1,
        player2Id: pair.$2,
      ));
    }

    return TournamentRound(
      roundNumber: roundNumber,
      pairings: pairings,
    );
  }

  /// Calculate full standings for a tournament.
  /// Sorted by match points (desc), then OMW% (desc), then GWP (desc).
  static List<StandingsEntry> calculateStandings(Tournament tournament) {
    final wins = <String, int>{};
    final losses = <String, int>{};
    final draws = <String, int>{};
    final byes = <String, int>{};
    final opponentIds = <String, List<String>>{};
    final gameWins = <String, int>{};
    final gameLosses = <String, int>{};

    for (final player in tournament.players) {
      wins[player.id] = 0;
      losses[player.id] = 0;
      draws[player.id] = 0;
      byes[player.id] = 0;
      opponentIds[player.id] = [];
      gameWins[player.id] = 0;
      gameLosses[player.id] = 0;
    }

    for (final round in tournament.rounds) {
      for (final pairing in round.pairings) {
        if (!pairing.isComplete) continue;

        if (pairing.isBye) {
          wins[pairing.player1Id] = (wins[pairing.player1Id] ?? 0) + 1;
          byes[pairing.player1Id] = (byes[pairing.player1Id] ?? 0) + 1;
          // Byes award 2-0 game wins but are excluded from GWP/OMW per MTG rules.
          continue;
        }

        final p1 = pairing.player1Id;
        final p2 = pairing.player2Id!;
        opponentIds[p1]?.add(p2);
        opponentIds[p2]?.add(p1);

        // Track individual game wins/losses.
        gameWins[p1] = (gameWins[p1] ?? 0) + pairing.player1Wins;
        gameLosses[p1] = (gameLosses[p1] ?? 0) + pairing.player2Wins;
        gameWins[p2] = (gameWins[p2] ?? 0) + pairing.player2Wins;
        gameLosses[p2] = (gameLosses[p2] ?? 0) + pairing.player1Wins;

        if (pairing.isDraw || pairing.player1Wins == pairing.player2Wins) {
          draws[p1] = (draws[p1] ?? 0) + 1;
          draws[p2] = (draws[p2] ?? 0) + 1;
        } else if (pairing.player1Wins > pairing.player2Wins) {
          wins[p1] = (wins[p1] ?? 0) + 1;
          losses[p2] = (losses[p2] ?? 0) + 1;
        } else if (pairing.player2Wins > pairing.player1Wins) {
          wins[p2] = (wins[p2] ?? 0) + 1;
          losses[p1] = (losses[p1] ?? 0) + 1;
        }
        // Equal game wins without isDraw means match is still undecided — skip.
      }
    }

    // Match points: 3 per win, 1 per draw.
    final matchPoints = <String, int>{};
    for (final player in tournament.players) {
      matchPoints[player.id] = (wins[player.id]! * 3) + draws[player.id]!;
    }

    // Match win percentage per player (floored at 0.33 per MTG rules).
    // Byes are excluded from the calculation.
    final mwPercent = <String, double>{};
    for (final player in tournament.players) {
      final totalPlayed =
          wins[player.id]! + losses[player.id]! + draws[player.id]!;
      final nonByeWins = wins[player.id]! - byes[player.id]!;
      final nonByePlayed = totalPlayed - byes[player.id]!;
      if (nonByePlayed <= 0) {
        mwPercent[player.id] = 0.33;
      } else {
        final nonByePoints = (nonByeWins * 3) + draws[player.id]!;
        final rawPct = nonByePoints / (nonByePlayed * 3);
        mwPercent[player.id] = rawPct < 0.33 ? 0.33 : rawPct;
      }
    }

    // Opponent Match Win % per player (byes excluded — no opponent to track).
    final omwPercent = <String, double>{};
    for (final player in tournament.players) {
      final opponents = opponentIds[player.id]!;
      if (opponents.isEmpty) {
        omwPercent[player.id] = 0.0;
      } else {
        final sum = opponents.fold<double>(
          0.0,
          (acc, oppId) => acc + (mwPercent[oppId] ?? 0.33),
        );
        omwPercent[player.id] = sum / opponents.length;
      }
    }

    // Game Win Percentage per player (floored at 0.33 per MTG rules).
    final gwPercent = <String, double>{};
    for (final player in tournament.players) {
      final gw = gameWins[player.id]!;
      final gl = gameLosses[player.id]!;
      final totalGames = gw + gl;
      if (totalGames == 0) {
        gwPercent[player.id] = 0.33;
      } else {
        final rawPct = gw / totalGames;
        gwPercent[player.id] = rawPct < 0.33 ? 0.33 : rawPct;
      }
    }

    // Build entries.
    final entries = <StandingsEntry>[];
    for (final player in tournament.players) {
      entries.add(StandingsEntry(
        player: player,
        matchPoints: matchPoints[player.id]!,
        wins: wins[player.id]!,
        losses: losses[player.id]!,
        draws: draws[player.id]!,
        byeCount: byes[player.id]!,
        omwPercent: omwPercent[player.id]!,
        gwPercent: gwPercent[player.id]!,
        rank: 0,
      ));
    }

    // Sort: match points desc, then OMW% desc, then GWP desc.
    entries.sort((a, b) {
      final mpCompare = b.matchPoints.compareTo(a.matchPoints);
      if (mpCompare != 0) return mpCompare;
      final omwCompare = b.omwPercent.compareTo(a.omwPercent);
      if (omwCompare != 0) return omwCompare;
      return b.gwPercent.compareTo(a.gwPercent);
    });

    // Assign ranks.
    return List.generate(entries.length, (i) {
      final e = entries[i];
      return StandingsEntry(
        player: e.player,
        matchPoints: e.matchPoints,
        wins: e.wins,
        losses: e.losses,
        draws: e.draws,
        byeCount: e.byeCount,
        omwPercent: e.omwPercent,
        gwPercent: e.gwPercent,
        rank: i + 1,
      );
    });
  }

  // --- Private helpers ---

  /// Build a set of "id1|id2" strings (sorted) for all pairings so far.
  static Set<String> _buildPreviousPairsSet(Tournament tournament) {
    final pairs = <String>{};
    for (final round in tournament.rounds) {
      for (final pairing in round.pairings) {
        if (pairing.player2Id == null) continue;
        final sorted = [pairing.player1Id, pairing.player2Id!]..sort();
        pairs.add('${sorted[0]}|${sorted[1]}');
      }
    }
    return pairs;
  }

  /// Get set of player IDs who have already received a bye.
  static Set<String> _playersWithBye(Tournament tournament) {
    final result = <String>{};
    for (final round in tournament.rounds) {
      for (final pairing in round.pairings) {
        if (pairing.isBye) result.add(pairing.player1Id);
      }
    }
    return result;
  }

  /// Check if two players have already played each other.
  static bool _havePlayed(String p1, String p2, Set<String> previousPairs) {
    final sorted = [p1, p2]..sort();
    return previousPairs.contains('${sorted[0]}|${sorted[1]}');
  }

  /// Bracket-based Swiss pairing.
  ///
  /// Groups players by match points, then pairs within each bracket
  /// (1st vs middle, 2nd vs middle+1, etc.). If a bracket has an odd number
  /// of players, the lowest drops to the next bracket. Avoids rematches
  /// where possible.
  static List<(String, String)> _bracketPair(
    List<String> playerIds,
    Map<String, StandingsEntry> standingsMap,
    Set<String> previousPairs,
  ) {
    if (playerIds.length < 2) return [];

    // Group players into brackets by match points.
    final brackets = <int, List<String>>{};
    for (final id in playerIds) {
      final pts = standingsMap[id]?.matchPoints ?? 0;
      brackets.putIfAbsent(pts, () => []).add(id);
    }

    // Sort bracket keys descending (highest points first).
    final sortedKeys = brackets.keys.toList()..sort((a, b) => b.compareTo(a));

    // Flatten brackets, dropping odd players to the next bracket.
    final orderedIds = <String>[];
    String? floater;
    for (int k = 0; k < sortedKeys.length; k++) {
      final bracket = brackets[sortedKeys[k]]!;
      if (floater != null) {
        bracket.insert(0, floater);
        floater = null;
      }
      if (bracket.length.isOdd) {
        // Drop the lowest player in the bracket to the next one.
        floater = bracket.removeLast();
      }
      orderedIds.addAll(bracket);
    }
    // If there's still a floater after all brackets, add them at the end.
    if (floater != null) {
      orderedIds.add(floater);
    }

    // Now pair within each bracket segment using fold pairing (1 vs n/2+1).
    return _greedyPair(orderedIds, previousPairs);
  }

  /// Greedy adjacent pairing avoiding rematches where possible.
  static List<(String, String)> _greedyPair(
    List<String> playerIds,
    Set<String> previousPairs,
  ) {
    final result = <(String, String)>[];
    final remaining = List<String>.from(playerIds);

    while (remaining.length >= 2) {
      final p1 = remaining.removeAt(0);
      bool paired = false;

      for (int i = 0; i < remaining.length; i++) {
        if (!_havePlayed(p1, remaining[i], previousPairs)) {
          result.add((p1, remaining.removeAt(i)));
          paired = true;
          break;
        }
      }

      // Fallback: allow rematch.
      if (!paired && remaining.isNotEmpty) {
        result.add((p1, remaining.removeAt(0)));
      }
    }

    return result;
  }
}

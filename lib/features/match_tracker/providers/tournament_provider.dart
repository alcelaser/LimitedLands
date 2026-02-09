import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tournament_models.dart';
import '../services/swiss_pairing_service.dart';

const _storageKey = 'tournaments_v1';

class TournamentState {
  final List<Tournament> tournaments;

  const TournamentState({this.tournaments = const []});
}

class TournamentNotifier extends StateNotifier<TournamentState> {
  TournamentNotifier() : super(const TournamentState()) {
    _loadFromStorage();
  }

  int _nextTournamentId = 1;
  int _nextPlayerId = 1;
  int _nextPairingId = 1;

  // --- Persistence ---

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final tournaments = list
          .map((e) => Tournament.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final t in tournaments) {
        _recoverIdCounter(t.id, 'tourn_', (n) {
          if (n >= _nextTournamentId) _nextTournamentId = n + 1;
        });
        for (final p in t.players) {
          _recoverIdCounter(p.id, 'tp_', (n) {
            if (n >= _nextPlayerId) _nextPlayerId = n + 1;
          });
        }
        for (final r in t.rounds) {
          for (final pair in r.pairings) {
            _recoverIdCounter(pair.id, 'pair_', (n) {
              if (n >= _nextPairingId) _nextPairingId = n + 1;
            });
          }
        }
      }
      state = TournamentState(tournaments: tournaments);
    } catch (_) {
      // Corrupted data: start fresh.
    }
  }

  void _recoverIdCounter(String id, String prefix, void Function(int) onFound) {
    if (id.startsWith(prefix)) {
      final num = int.tryParse(id.substring(prefix.length));
      if (num != null) onFound(num);
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.tournaments.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  // --- Tournament CRUD ---

  Tournament createTournament({
    String name = 'New Tournament',
    String format = 'Limited',
    int totalRounds = 3,
  }) {
    final tournament = Tournament(
      id: 'tourn_${_nextTournamentId++}',
      name: name,
      format: format,
      totalRounds: totalRounds,
    );
    state = TournamentState(
      tournaments: [tournament, ...state.tournaments],
    );
    _saveToStorage();
    return tournament;
  }

  void deleteTournament(String id) {
    state = TournamentState(
      tournaments: state.tournaments.where((t) => t.id != id).toList(),
    );
    _saveToStorage();
  }

  void updateTournament(Tournament updated) {
    state = TournamentState(
      tournaments: state.tournaments
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
    _saveToStorage();
  }

  // --- Player Management ---

  TournamentPlayer? addPlayer(String tournamentId, String playerName) {
    final tournament = _find(tournamentId);
    if (tournament == null || tournament.status != TournamentStatus.setup) {
      return null;
    }
    final player = TournamentPlayer(
      id: 'tp_${_nextPlayerId++}',
      name: playerName,
    );
    updateTournament(tournament.copyWith(
      players: [...tournament.players, player],
    ));
    return player;
  }

  void removePlayer(String tournamentId, String playerId) {
    final tournament = _find(tournamentId);
    if (tournament == null || tournament.status != TournamentStatus.setup) {
      return;
    }
    updateTournament(tournament.copyWith(
      players: tournament.players.where((p) => p.id != playerId).toList(),
    ));
  }

  // --- Tournament Lifecycle ---

  void startTournament(String tournamentId) {
    final tournament = _find(tournamentId);
    if (tournament == null || tournament.status != TournamentStatus.setup) {
      return;
    }
    if (tournament.players.length < 2) return;

    final recRounds =
        SwissPairingService.recommendedRounds(tournament.players.length);

    updateTournament(tournament.copyWith(
      status: TournamentStatus.inProgress,
      totalRounds:
          tournament.totalRounds > 0 ? tournament.totalRounds : recRounds,
    ));
  }

  void generateNextRound(String tournamentId) {
    final tournament = _find(tournamentId);
    if (tournament == null || !tournament.canGenerateNextRound) return;

    final newRound = SwissPairingService.generateNextRound(
      tournament: tournament,
      nextPairingIdStart: _nextPairingId,
    );

    _nextPairingId += newRound.pairings.length;

    updateTournament(tournament.copyWith(
      rounds: [...tournament.rounds, newRound],
    ));
  }

  // --- Result Reporting ---

  void reportResult(
    String tournamentId,
    int roundNumber,
    String pairingId, {
    required int player1Wins,
    required int player2Wins,
    bool isDraw = false,
    bool isComplete = true,
  }) {
    final tournament = _find(tournamentId);
    if (tournament == null) return;

    final roundIndex =
        tournament.rounds.indexWhere((r) => r.roundNumber == roundNumber);
    if (roundIndex < 0) return;

    final round = tournament.rounds[roundIndex];
    final updatedPairings = round.pairings.map((p) {
      if (p.id != pairingId) return p;
      return p.copyWith(
        player1Wins: player1Wins,
        player2Wins: player2Wins,
        isDraw: isDraw,
        isComplete: isComplete,
      );
    }).toList();

    final updatedRounds = List<TournamentRound>.from(tournament.rounds);
    updatedRounds[roundIndex] = round.copyWith(pairings: updatedPairings);

    updateTournament(tournament.copyWith(rounds: updatedRounds));
  }

  void resetPairing(
    String tournamentId,
    int roundNumber,
    String pairingId,
  ) {
    final tournament = _find(tournamentId);
    if (tournament == null) return;

    final roundIndex =
        tournament.rounds.indexWhere((r) => r.roundNumber == roundNumber);
    if (roundIndex < 0) return;

    final round = tournament.rounds[roundIndex];
    final updatedPairings = round.pairings.map((p) {
      if (p.id != pairingId) return p;
      return p.copyWith(
        player1Wins: 0,
        player2Wins: 0,
        isDraw: false,
        isComplete: false,
      );
    }).toList();

    final updatedRounds = List<TournamentRound>.from(tournament.rounds);
    updatedRounds[roundIndex] = round.copyWith(pairings: updatedPairings);

    updateTournament(tournament.copyWith(rounds: updatedRounds));
  }

  void completeTournament(String tournamentId) {
    final tournament = _find(tournamentId);
    if (tournament == null) return;
    updateTournament(tournament.copyWith(
      status: TournamentStatus.completed,
    ));
  }

  // --- Private helpers ---

  Tournament? _find(String id) {
    for (final t in state.tournaments) {
      if (t.id == id) return t;
    }
    return null;
  }
}

final tournamentProvider =
    StateNotifierProvider<TournamentNotifier, TournamentState>(
  (ref) => TournamentNotifier(),
);

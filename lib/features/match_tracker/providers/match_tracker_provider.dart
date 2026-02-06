import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'match_tracker_v1';

enum MatchResult { win, loss, draw, inProgress }

class MatchRecord {
  final String id;
  final String opponentName;
  final int gamesWon;
  final int gamesLost;
  final bool isDraw;
  final int roundNumber;

  const MatchRecord({
    required this.id,
    this.opponentName = '',
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.isDraw = false,
    required this.roundNumber,
  });

  MatchResult get result {
    if (isDraw) return MatchResult.draw;
    if (gamesWon >= 2) return MatchResult.win;
    if (gamesLost >= 2) return MatchResult.loss;
    return MatchResult.inProgress;
  }

  bool get isComplete => result != MatchResult.inProgress;

  MatchRecord copyWith({
    String? opponentName,
    int? gamesWon,
    int? gamesLost,
    bool? isDraw,
  }) {
    return MatchRecord(
      id: id,
      opponentName: opponentName ?? this.opponentName,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      isDraw: isDraw ?? this.isDraw,
      roundNumber: roundNumber,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'opponentName': opponentName,
        'gamesWon': gamesWon,
        'gamesLost': gamesLost,
        'isDraw': isDraw,
        'roundNumber': roundNumber,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      opponentName: json['opponentName'] as String? ?? '',
      gamesWon: json['gamesWon'] as int? ?? 0,
      gamesLost: json['gamesLost'] as int? ?? 0,
      isDraw: json['isDraw'] as bool? ?? false,
      roundNumber: json['roundNumber'] as int? ?? 1,
    );
  }
}

class Event {
  final String id;
  final String name;
  final String format;
  final List<MatchRecord> matches;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    this.format = 'Limited',
    this.matches = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get wins => matches.where((m) => m.result == MatchResult.win).length;
  int get losses => matches.where((m) => m.result == MatchResult.loss).length;
  int get draws => matches.where((m) => m.result == MatchResult.draw).length;
  String get record => '$wins-$losses${draws > 0 ? '-$draws' : ''}';
  int get matchCount => matches.length;
  int get completedCount => matches.where((m) => m.isComplete).length;

  Event copyWith({
    String? name,
    String? format,
    List<MatchRecord>? matches,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id,
      name: name ?? this.name,
      format: format ?? this.format,
      matches: matches ?? this.matches,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'format': format,
        'matches': matches.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String? ?? 'Limited',
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => MatchRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class MatchTrackerState {
  final List<Event> events;

  const MatchTrackerState({this.events = const []});
}

class MatchTrackerNotifier extends StateNotifier<MatchTrackerState> {
  MatchTrackerNotifier() : super(const MatchTrackerState()) {
    _loadFromStorage();
  }

  int _nextEventId = 1;
  int _nextMatchId = 1;

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final events = list
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final event in events) {
        final eParts = event.id.split('_');
        if (eParts.length == 2) {
          final num = int.tryParse(eParts[1]);
          if (num != null && num >= _nextEventId) _nextEventId = num + 1;
        }
        for (final match in event.matches) {
          final mParts = match.id.split('_');
          if (mParts.length == 2) {
            final num = int.tryParse(mParts[1]);
            if (num != null && num >= _nextMatchId) _nextMatchId = num + 1;
          }
        }
      }
      state = MatchTrackerState(events: events);
    } catch (_) {
      // Corrupted data: start fresh
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.events.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Event createEvent({String name = 'New Event', String format = 'Limited'}) {
    final event = Event(
      id: 'event_${_nextEventId++}',
      name: name,
      format: format,
    );
    state = MatchTrackerState(events: [event, ...state.events]);
    _saveToStorage();
    return event;
  }

  void deleteEvent(String id) {
    state = MatchTrackerState(
      events: state.events.where((e) => e.id != id).toList(),
    );
    _saveToStorage();
  }

  void updateEvent(Event updated) {
    state = MatchTrackerState(
      events:
          state.events.map((e) => e.id == updated.id ? updated : e).toList(),
    );
    _saveToStorage();
  }

  MatchRecord addMatch(String eventId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final match = MatchRecord(
      id: 'match_${_nextMatchId++}',
      roundNumber: event.matches.length + 1,
    );
    updateEvent(event.copyWith(matches: [...event.matches, match]));
    return match;
  }

  void updateMatch(String eventId, MatchRecord updated) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final newMatches = event.matches
        .map((m) => m.id == updated.id ? updated : m)
        .toList();
    updateEvent(event.copyWith(matches: newMatches));
  }

  void removeMatch(String eventId, String matchId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final newMatches = event.matches.where((m) => m.id != matchId).toList();
    // Re-number rounds
    final renumbered = List.generate(
      newMatches.length,
      (i) => MatchRecord(
        id: newMatches[i].id,
        opponentName: newMatches[i].opponentName,
        gamesWon: newMatches[i].gamesWon,
        gamesLost: newMatches[i].gamesLost,
        isDraw: newMatches[i].isDraw,
        roundNumber: i + 1,
      ),
    );
    updateEvent(event.copyWith(matches: renumbered));
  }

  void recordGameWin(String eventId, String matchId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final match = event.matches.firstWhere((m) => m.id == matchId);
    if (match.isComplete) return;
    updateMatch(eventId, match.copyWith(gamesWon: match.gamesWon + 1));
  }

  void recordGameLoss(String eventId, String matchId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final match = event.matches.firstWhere((m) => m.id == matchId);
    if (match.isComplete) return;
    updateMatch(eventId, match.copyWith(gamesLost: match.gamesLost + 1));
  }

  void toggleDraw(String eventId, String matchId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final match = event.matches.firstWhere((m) => m.id == matchId);
    updateMatch(eventId, match.copyWith(
      isDraw: !match.isDraw,
      gamesWon: 0,
      gamesLost: 0,
    ));
  }

  void resetMatch(String eventId, String matchId) {
    final event = state.events.firstWhere((e) => e.id == eventId);
    final match = event.matches.firstWhere((m) => m.id == matchId);
    updateMatch(eventId, match.copyWith(
      gamesWon: 0,
      gamesLost: 0,
      isDraw: false,
    ));
  }
}

final matchTrackerProvider =
    StateNotifierProvider<MatchTrackerNotifier, MatchTrackerState>(
  (ref) => MatchTrackerNotifier(),
);

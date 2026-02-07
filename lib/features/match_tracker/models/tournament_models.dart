enum TournamentStatus { setup, inProgress, completed }

class TournamentPlayer {
  final String id;
  final String name;

  const TournamentPlayer({required this.id, required this.name});

  TournamentPlayer copyWith({String? name}) {
    return TournamentPlayer(id: id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory TournamentPlayer.fromJson(Map<String, dynamic> json) {
    return TournamentPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class TournamentPairing {
  final String id;
  final String player1Id;
  final String? player2Id;
  final int player1Wins;
  final int player2Wins;
  final bool isDraw;
  final bool isComplete;

  const TournamentPairing({
    required this.id,
    required this.player1Id,
    this.player2Id,
    this.player1Wins = 0,
    this.player2Wins = 0,
    this.isDraw = false,
    this.isComplete = false,
  });

  bool get isBye => player2Id == null;

  TournamentPairing copyWith({
    int? player1Wins,
    int? player2Wins,
    bool? isDraw,
    bool? isComplete,
  }) {
    return TournamentPairing(
      id: id,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Wins: player1Wins ?? this.player1Wins,
      player2Wins: player2Wins ?? this.player2Wins,
      isDraw: isDraw ?? this.isDraw,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'player1Id': player1Id,
        'player2Id': player2Id,
        'player1Wins': player1Wins,
        'player2Wins': player2Wins,
        'isDraw': isDraw,
        'isComplete': isComplete,
      };

  factory TournamentPairing.fromJson(Map<String, dynamic> json) {
    return TournamentPairing(
      id: json['id'] as String,
      player1Id: json['player1Id'] as String,
      player2Id: json['player2Id'] as String?,
      player1Wins: json['player1Wins'] as int? ?? 0,
      player2Wins: json['player2Wins'] as int? ?? 0,
      isDraw: json['isDraw'] as bool? ?? false,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}

class TournamentRound {
  final int roundNumber;
  final List<TournamentPairing> pairings;

  const TournamentRound({
    required this.roundNumber,
    this.pairings = const [],
  });

  bool get isComplete =>
      pairings.isNotEmpty && pairings.every((p) => p.isComplete);

  TournamentRound copyWith({List<TournamentPairing>? pairings}) {
    return TournamentRound(
      roundNumber: roundNumber,
      pairings: pairings ?? this.pairings,
    );
  }

  Map<String, dynamic> toJson() => {
        'roundNumber': roundNumber,
        'pairings': pairings.map((p) => p.toJson()).toList(),
      };

  factory TournamentRound.fromJson(Map<String, dynamic> json) {
    return TournamentRound(
      roundNumber: json['roundNumber'] as int,
      pairings: (json['pairings'] as List<dynamic>?)
              ?.map((e) =>
                  TournamentPairing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Tournament {
  final String id;
  final String name;
  final String format;
  final int totalRounds;
  final List<TournamentPlayer> players;
  final List<TournamentRound> rounds;
  final TournamentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tournament({
    required this.id,
    required this.name,
    this.format = 'Limited',
    this.totalRounds = 3,
    this.players = const [],
    this.rounds = const [],
    this.status = TournamentStatus.setup,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get currentRoundNumber => rounds.length;

  bool get canGenerateNextRound =>
      status == TournamentStatus.inProgress &&
      currentRoundNumber < totalRounds &&
      (rounds.isEmpty || rounds.last.isComplete);

  bool get isComplete =>
      currentRoundNumber >= totalRounds &&
      rounds.every((r) => r.isComplete);

  Tournament copyWith({
    String? name,
    String? format,
    int? totalRounds,
    List<TournamentPlayer>? players,
    List<TournamentRound>? rounds,
    TournamentStatus? status,
    DateTime? updatedAt,
  }) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      format: format ?? this.format,
      totalRounds: totalRounds ?? this.totalRounds,
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'format': format,
        'totalRounds': totalRounds,
        'players': players.map((p) => p.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      format: json['format'] as String? ?? 'Limited',
      totalRounds: json['totalRounds'] as int? ?? 3,
      players: (json['players'] as List<dynamic>?)
              ?.map((e) =>
                  TournamentPlayer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((e) =>
                  TournamentRound.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: TournamentStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? 'setup'),
        orElse: () => TournamentStatus.setup,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class StandingsEntry {
  final TournamentPlayer player;
  final int matchPoints;
  final int wins;
  final int losses;
  final int draws;
  final int byeCount;
  final double omwPercent;
  final int rank;

  const StandingsEntry({
    required this.player,
    required this.matchPoints,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.byeCount,
    required this.omwPercent,
    required this.rank,
  });

  String get record => '$wins-$losses${draws > 0 ? '-$draws' : ''}';
}

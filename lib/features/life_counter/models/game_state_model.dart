import 'player_model.dart';

enum GameFormat { standard, commander, custom }

/// Pre-game configuration set on the setup screen.
class GameConfig {
  final int playerCount;
  final int startingLife;
  final GameFormat format;
  final bool planechaseEnabled;
  final bool partnerEnabled;

  const GameConfig({
    this.playerCount = 2,
    this.startingLife = 20,
    this.format = GameFormat.standard,
    this.planechaseEnabled = false,
    this.partnerEnabled = false,
  });

  GameConfig copyWith({
    int? playerCount,
    int? startingLife,
    GameFormat? format,
    bool? planechaseEnabled,
    bool? partnerEnabled,
  }) {
    return GameConfig(
      playerCount: playerCount ?? this.playerCount,
      startingLife: startingLife ?? this.startingLife,
      format: format ?? this.format,
      planechaseEnabled: planechaseEnabled ?? this.planechaseEnabled,
      partnerEnabled: partnerEnabled ?? this.partnerEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'playerCount': playerCount,
        'startingLife': startingLife,
        'format': format.name,
        'planechaseEnabled': planechaseEnabled,
        'partnerEnabled': partnerEnabled,
      };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      playerCount: json['playerCount'] as int? ?? 2,
      startingLife: json['startingLife'] as int? ?? 20,
      format: GameFormat.values.firstWhere(
        (f) => f.name == (json['format'] as String? ?? 'standard'),
        orElse: () => GameFormat.standard,
      ),
      planechaseEnabled: json['planechaseEnabled'] as bool? ?? false,
      partnerEnabled: json['partnerEnabled'] as bool? ?? false,
    );
  }
}

/// Complete game state managed by GameNotifier.
class GameState {
  final List<PlayerState> players;
  final GameConfig config;
  final int activePlayerIndex;
  final int turnNumber;
  final bool isGameActive;

  const GameState({
    this.players = const [],
    this.config = const GameConfig(),
    this.activePlayerIndex = 0,
    this.turnNumber = 1,
    this.isGameActive = false,
  });

  PlayerState? get activePlayer =>
      activePlayerIndex < players.length ? players[activePlayerIndex] : null;

  GameState copyWith({
    List<PlayerState>? players,
    GameConfig? config,
    int? activePlayerIndex,
    int? turnNumber,
    bool? isGameActive,
  }) {
    return GameState(
      players: players ?? this.players,
      config: config ?? this.config,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      turnNumber: turnNumber ?? this.turnNumber,
      isGameActive: isGameActive ?? this.isGameActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'config': config.toJson(),
        'activePlayerIndex': activePlayerIndex,
        'turnNumber': turnNumber,
        'isGameActive': isGameActive,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List<dynamic>?)
              ?.map(
                  (e) => PlayerState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      config: json['config'] != null
          ? GameConfig.fromJson(json['config'] as Map<String, dynamic>)
          : const GameConfig(),
      activePlayerIndex: json['activePlayerIndex'] as int? ?? 0,
      turnNumber: json['turnNumber'] as int? ?? 1,
      isGameActive: json['isGameActive'] as bool? ?? false,
    );
  }
}

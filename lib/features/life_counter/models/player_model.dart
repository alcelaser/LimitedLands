/// A user-defined counter with a custom label.
class CustomCounter {
  final String id;
  final String label;
  final int value;

  const CustomCounter({
    required this.id,
    required this.label,
    this.value = 0,
  });

  CustomCounter copyWith({String? label, int? value}) {
    return CustomCounter(
      id: id,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'value': value,
      };

  factory CustomCounter.fromJson(Map<String, dynamic> json) {
    return CustomCounter(
      id: json['id'] as String,
      label: json['label'] as String,
      value: json['value'] as int? ?? 0,
    );
  }
}

/// Complete state for a single player in the game.
class PlayerState {
  final String id;
  final String name;
  final int life;
  final int poison;
  final int experience;
  final int energy;
  final int stormCount;
  final int commanderTax;

  /// Commander damage received FROM each other player.
  /// Key: source player ID, Value: total damage from that player's commander.
  final Map<String, int> commanderDamageReceived;

  /// Partner commander damage received FROM each other player.
  /// Key: source player ID, Value: total damage from that player's partner.
  final Map<String, int> partnerDamageReceived;

  /// Floating mana pool. Keys: 'W', 'U', 'B', 'R', 'G', 'C'.
  final Map<String, int> manaPool;

  /// User-defined custom counters.
  final List<CustomCounter> customCounters;

  /// Background color index (refers to a predefined palette).
  final int colorIndex;

  /// Whether this player is alive (false = grayed out / killed).
  final bool isAlive;

  /// History of life-total deltas for undo/display.
  final List<int> lifeHistory;

  const PlayerState({
    required this.id,
    this.name = '',
    this.life = 20,
    this.poison = 0,
    this.experience = 0,
    this.energy = 0,
    this.stormCount = 0,
    this.commanderTax = 0,
    this.commanderDamageReceived = const {},
    this.partnerDamageReceived = const {},
    this.manaPool = const {},
    this.customCounters = const [],
    this.colorIndex = 0,
    this.isAlive = true,
    this.lifeHistory = const [],
  });

  /// Check if any single commander source has dealt >= 21 damage.
  /// Returns the source player ID if lethal, null otherwise.
  String? get lethalCommanderSource {
    for (final entry in commanderDamageReceived.entries) {
      if (entry.value >= 21) return entry.key;
    }
    for (final entry in partnerDamageReceived.entries) {
      if (entry.value >= 21) return entry.key;
    }
    return null;
  }

  /// Whether poison count has reached the lethal threshold of 10.
  bool get isPoisonLethal => poison >= 10;

  PlayerState copyWith({
    String? name,
    int? life,
    int? poison,
    int? experience,
    int? energy,
    int? stormCount,
    int? commanderTax,
    Map<String, int>? commanderDamageReceived,
    Map<String, int>? partnerDamageReceived,
    Map<String, int>? manaPool,
    List<CustomCounter>? customCounters,
    int? colorIndex,
    bool? isAlive,
    List<int>? lifeHistory,
  }) {
    return PlayerState(
      id: id,
      name: name ?? this.name,
      life: life ?? this.life,
      poison: poison ?? this.poison,
      experience: experience ?? this.experience,
      energy: energy ?? this.energy,
      stormCount: stormCount ?? this.stormCount,
      commanderTax: commanderTax ?? this.commanderTax,
      commanderDamageReceived:
          commanderDamageReceived ?? this.commanderDamageReceived,
      partnerDamageReceived:
          partnerDamageReceived ?? this.partnerDamageReceived,
      manaPool: manaPool ?? this.manaPool,
      customCounters: customCounters ?? this.customCounters,
      colorIndex: colorIndex ?? this.colorIndex,
      isAlive: isAlive ?? this.isAlive,
      lifeHistory: lifeHistory ?? this.lifeHistory,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'life': life,
        'poison': poison,
        'experience': experience,
        'energy': energy,
        'stormCount': stormCount,
        'commanderTax': commanderTax,
        'commanderDamageReceived': commanderDamageReceived,
        'partnerDamageReceived': partnerDamageReceived,
        'manaPool': manaPool,
        'customCounters': customCounters.map((c) => c.toJson()).toList(),
        'colorIndex': colorIndex,
        'isAlive': isAlive,
        'lifeHistory': lifeHistory,
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      life: json['life'] as int? ?? 20,
      poison: json['poison'] as int? ?? 0,
      experience: json['experience'] as int? ?? 0,
      energy: json['energy'] as int? ?? 0,
      stormCount: json['stormCount'] as int? ?? 0,
      commanderTax: json['commanderTax'] as int? ?? 0,
      commanderDamageReceived: Map<String, int>.from(
        json['commanderDamageReceived'] as Map? ?? {},
      ),
      partnerDamageReceived: Map<String, int>.from(
        json['partnerDamageReceived'] as Map? ?? {},
      ),
      manaPool: Map<String, int>.from(json['manaPool'] as Map? ?? {}),
      customCounters: (json['customCounters'] as List<dynamic>?)
              ?.map((e) => CustomCounter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      colorIndex: json['colorIndex'] as int? ?? 0,
      isAlive: json['isAlive'] as bool? ?? true,
      lifeHistory: List<int>.from(json['lifeHistory'] as List? ?? []),
    );
  }
}

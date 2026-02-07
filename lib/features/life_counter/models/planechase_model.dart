enum PlanarDieResult { planeswalk, chaos, blank }

class PlanarCard {
  final String id;
  final String name;
  final String typeLine;
  final String? imageUrl;
  final String setCode;

  const PlanarCard({
    required this.id,
    required this.name,
    this.typeLine = '',
    this.imageUrl,
    this.setCode = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'typeLine': typeLine,
        'imageUrl': imageUrl,
        'setCode': setCode,
      };

  factory PlanarCard.fromJson(Map<String, dynamic> json) {
    return PlanarCard(
      id: json['id'] as String,
      name: json['name'] as String,
      typeLine: json['typeLine'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      setCode: json['setCode'] as String? ?? '',
    );
  }
}

class PlanechaseState {
  final List<PlanarCard> deck;
  final List<PlanarCard> discard;
  final PlanarCard? currentPlane;
  final PlanarDieResult? lastDieRoll;
  final bool isInitialized;

  const PlanechaseState({
    this.deck = const [],
    this.discard = const [],
    this.currentPlane,
    this.lastDieRoll,
    this.isInitialized = false,
  });

  PlanechaseState copyWith({
    List<PlanarCard>? deck,
    List<PlanarCard>? discard,
    PlanarCard? currentPlane,
    PlanarDieResult? lastDieRoll,
    bool? isInitialized,
    bool clearCurrentPlane = false,
    bool clearLastDieRoll = false,
  }) {
    return PlanechaseState(
      deck: deck ?? this.deck,
      discard: discard ?? this.discard,
      currentPlane:
          clearCurrentPlane ? null : (currentPlane ?? this.currentPlane),
      lastDieRoll:
          clearLastDieRoll ? null : (lastDieRoll ?? this.lastDieRoll),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

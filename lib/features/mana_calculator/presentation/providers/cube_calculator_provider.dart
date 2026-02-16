import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mtg_constants.dart';

class CubeManaSource {
  final String name;
  final String type; // 'fast' or 'paid'
  final List<String> colorsProduced; // empty = colorless
  final int count;

  const CubeManaSource({
    required this.name,
    required this.type,
    this.colorsProduced = const [],
    this.count = 0,
  });

  CubeManaSource copyWith({int? count}) {
    return CubeManaSource(
      name: name,
      type: type,
      colorsProduced: colorsProduced,
      count: count ?? this.count,
    );
  }
}

class CubeLandResult {
  final String manaType;
  final int count;
  final double percentage;
  final bool isSplash;

  const CubeLandResult({
    required this.manaType,
    required this.count,
    required this.percentage,
    this.isSplash = false,
  });
}

class CubeRecommendation {
  final List<CubeLandResult> landCounts;
  final int totalLands;
  final int basicLandCount;
  final int nonbasicLandCount;
  final int totalManaSourcesIncludingLands;
  final List<String> warnings;
  final List<String> tips;

  const CubeRecommendation({
    this.landCounts = const [],
    this.totalLands = 0,
    this.basicLandCount = 0,
    this.nonbasicLandCount = 0,
    this.totalManaSourcesIncludingLands = 0,
    this.warnings = const [],
    this.tips = const [],
  });
}

class CubeCalculatorState {
  final Map<String, int> symbolCounts;
  final int deckSize;
  final int targetManaSourceCount;
  final List<CubeManaSource> fastManaSources;
  final List<CubeManaSource> paidManaSources;
  final List<CubeManaSource> fetchLands;
  final List<CubeManaSource> dualLands;
  final List<CubeManaSource> shockLands;
  final List<CubeManaSource> surveilLands;
  final List<CubeManaSource> triomeLands;
  final List<CubeManaSource> utilityLands;
  final CubeRecommendation recommendation;

  const CubeCalculatorState({
    this.symbolCounts = const {},
    this.deckSize = 40,
    this.targetManaSourceCount = 17,
    this.fastManaSources = const [],
    this.paidManaSources = const [],
    this.fetchLands = const [],
    this.dualLands = const [],
    this.shockLands = const [],
    this.surveilLands = const [],
    this.triomeLands = const [],
    this.utilityLands = const [],
    this.recommendation = const CubeRecommendation(),
  });

  CubeCalculatorState copyWith({
    Map<String, int>? symbolCounts,
    int? deckSize,
    int? targetManaSourceCount,
    List<CubeManaSource>? fastManaSources,
    List<CubeManaSource>? paidManaSources,
    List<CubeManaSource>? fetchLands,
    List<CubeManaSource>? dualLands,
    List<CubeManaSource>? shockLands,
    List<CubeManaSource>? surveilLands,
    List<CubeManaSource>? triomeLands,
    List<CubeManaSource>? utilityLands,
    CubeRecommendation? recommendation,
  }) {
    return CubeCalculatorState(
      symbolCounts: symbolCounts ?? this.symbolCounts,
      deckSize: deckSize ?? this.deckSize,
      targetManaSourceCount:
          targetManaSourceCount ?? this.targetManaSourceCount,
      fastManaSources: fastManaSources ?? this.fastManaSources,
      paidManaSources: paidManaSources ?? this.paidManaSources,
      fetchLands: fetchLands ?? this.fetchLands,
      dualLands: dualLands ?? this.dualLands,
      shockLands: shockLands ?? this.shockLands,
      surveilLands: surveilLands ?? this.surveilLands,
      triomeLands: triomeLands ?? this.triomeLands,
      utilityLands: utilityLands ?? this.utilityLands,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  int get totalFastMana =>
      fastManaSources.fold<int>(0, (sum, s) => sum + s.count);
  int get totalPaidMana =>
      paidManaSources.fold<int>(0, (sum, s) => sum + s.count);
  int get totalNonLandMana => totalFastMana + totalPaidMana;
  int get landsNeeded => (targetManaSourceCount - totalNonLandMana)
      .clamp(0, targetManaSourceCount);
  int get totalNonbasicLands => [
        ...fetchLands,
        ...dualLands,
        ...shockLands,
        ...surveilLands,
        ...triomeLands,
        ...utilityLands
      ].fold<int>(0, (sum, s) => sum + s.count);
  int get basicLandsNeeded =>
      (landsNeeded - totalNonbasicLands).clamp(0, landsNeeded);
}

// Default fast mana sources available in Vintage Cube
List<CubeManaSource> defaultFastManaSources() => const [
      CubeManaSource(
          name: 'Black Lotus',
          type: 'fast',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(name: 'Mox Sapphire', type: 'fast', colorsProduced: ['U']),
      CubeManaSource(name: 'Mox Jet', type: 'fast', colorsProduced: ['B']),
      CubeManaSource(name: 'Mox Ruby', type: 'fast', colorsProduced: ['R']),
      CubeManaSource(name: 'Mox Pearl', type: 'fast', colorsProduced: ['W']),
      CubeManaSource(name: 'Mox Emerald', type: 'fast', colorsProduced: ['G']),
      CubeManaSource(
          name: 'Chrome Mox',
          type: 'fast',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(
          name: 'Mox Diamond',
          type: 'fast',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(
          name: 'Lotus Petal',
          type: 'fast',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(name: 'Mana Crypt', type: 'fast', colorsProduced: []),
      CubeManaSource(
          name: 'Mox Opal',
          type: 'fast',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
    ];

List<CubeManaSource> defaultPaidManaSources() => const [
      CubeManaSource(name: 'Sol Ring', type: 'paid', colorsProduced: []),
      CubeManaSource(name: 'Grim Monolith', type: 'paid', colorsProduced: []),
      CubeManaSource(name: 'Mana Vault', type: 'paid', colorsProduced: []),
      CubeManaSource(name: 'Mind Stone', type: 'paid', colorsProduced: []),
      CubeManaSource(name: 'Worn Powerstone', type: 'paid', colorsProduced: []),
      CubeManaSource(name: 'Thran Dynamo', type: 'paid', colorsProduced: []),
      CubeManaSource(
          name: 'Coalition Relic',
          type: 'paid',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(
          name: 'Chromatic Lantern',
          type: 'paid',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(name: 'Basalt Monolith', type: 'paid', colorsProduced: []),
      CubeManaSource(
          name: 'Everflowing Chalice', type: 'paid', colorsProduced: []),
      CubeManaSource(
          name: 'Signets / Talismans',
          type: 'paid',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
    ];

// Default fetch lands available in Vintage Cube
List<CubeManaSource> defaultFetchLands() => const [
      CubeManaSource(
          name: 'Flooded Strand', type: 'land', colorsProduced: ['W', 'U']),
      CubeManaSource(
          name: 'Polluted Delta', type: 'land', colorsProduced: ['U', 'B']),
      CubeManaSource(
          name: 'Bloodstained Mire', type: 'land', colorsProduced: ['B', 'R']),
      CubeManaSource(
          name: 'Wooded Foothills', type: 'land', colorsProduced: ['R', 'G']),
      CubeManaSource(
          name: 'Windswept Heath', type: 'land', colorsProduced: ['G', 'W']),
      CubeManaSource(
          name: 'Marsh Flats', type: 'land', colorsProduced: ['W', 'B']),
      CubeManaSource(
          name: 'Scalding Tarn', type: 'land', colorsProduced: ['U', 'R']),
      CubeManaSource(
          name: 'Verdant Catacombs', type: 'land', colorsProduced: ['B', 'G']),
      CubeManaSource(
          name: 'Arid Mesa', type: 'land', colorsProduced: ['R', 'W']),
      CubeManaSource(
          name: 'Misty Rainforest', type: 'land', colorsProduced: ['G', 'U']),
    ];

// Default dual lands available in Vintage Cube (ABUR duals)
List<CubeManaSource> defaultDualLands() => const [
      CubeManaSource(name: 'Tundra', type: 'land', colorsProduced: ['W', 'U']),
      CubeManaSource(
          name: 'Underground Sea', type: 'land', colorsProduced: ['U', 'B']),
      CubeManaSource(
          name: 'Badlands', type: 'land', colorsProduced: ['B', 'R']),
      CubeManaSource(name: 'Taiga', type: 'land', colorsProduced: ['R', 'G']),
      CubeManaSource(
          name: 'Savannah', type: 'land', colorsProduced: ['G', 'W']),
      CubeManaSource(
          name: 'Scrubland', type: 'land', colorsProduced: ['W', 'B']),
      CubeManaSource(
          name: 'Volcanic Island', type: 'land', colorsProduced: ['U', 'R']),
      CubeManaSource(name: 'Bayou', type: 'land', colorsProduced: ['B', 'G']),
      CubeManaSource(name: 'Plateau', type: 'land', colorsProduced: ['R', 'W']),
      CubeManaSource(
          name: 'Tropical Island', type: 'land', colorsProduced: ['G', 'U']),
    ];

// Default shock lands (Ravnica)
List<CubeManaSource> defaultShockLands() => const [
      CubeManaSource(
          name: 'Hallowed Fountain', type: 'land', colorsProduced: ['W', 'U']),
      CubeManaSource(
          name: 'Watery Grave', type: 'land', colorsProduced: ['U', 'B']),
      CubeManaSource(
          name: 'Blood Crypt', type: 'land', colorsProduced: ['B', 'R']),
      CubeManaSource(
          name: 'Stomping Ground', type: 'land', colorsProduced: ['R', 'G']),
      CubeManaSource(
          name: 'Temple Garden', type: 'land', colorsProduced: ['G', 'W']),
      CubeManaSource(
          name: 'Godless Shrine', type: 'land', colorsProduced: ['W', 'B']),
      CubeManaSource(
          name: 'Steam Vents', type: 'land', colorsProduced: ['U', 'R']),
      CubeManaSource(
          name: 'Overgrown Tomb', type: 'land', colorsProduced: ['B', 'G']),
      CubeManaSource(
          name: 'Sacred Foundry', type: 'land', colorsProduced: ['R', 'W']),
      CubeManaSource(
          name: 'Breeding Pool', type: 'land', colorsProduced: ['G', 'U']),
    ];

// Default surveil lands (Murders at Karlov Manor)
List<CubeManaSource> defaultSurveilLands() => const [
      CubeManaSource(
          name: 'Meticulous Archive', type: 'land', colorsProduced: ['W', 'U']),
      CubeManaSource(
          name: 'Undercity Sewers', type: 'land', colorsProduced: ['U', 'B']),
      CubeManaSource(
          name: 'Shadowy Backstreet', type: 'land', colorsProduced: ['W', 'B']),
      CubeManaSource(
          name: 'Raucous Theater', type: 'land', colorsProduced: ['B', 'R']),
      CubeManaSource(
          name: 'Lush Portico', type: 'land', colorsProduced: ['G', 'W']),
      CubeManaSource(
          name: 'Elegant Parlor', type: 'land', colorsProduced: ['W', 'R']),
      CubeManaSource(
          name: 'Commercial District',
          type: 'land',
          colorsProduced: ['R', 'G']),
      CubeManaSource(
          name: 'Underground Mortuary',
          type: 'land',
          colorsProduced: ['B', 'G']),
      CubeManaSource(
          name: 'Thundering Falls', type: 'land', colorsProduced: ['R', 'U']),
      CubeManaSource(
          name: 'Hedge Maze', type: 'land', colorsProduced: ['G', 'U']),
    ];

// Default triome lands (Ikoria + Streets of New Capenna)
List<CubeManaSource> defaultTriomeLands() => const [
      CubeManaSource(
          name: 'Indatha Triome',
          type: 'land',
          colorsProduced: ['W', 'B', 'G']),
      CubeManaSource(
          name: 'Ketria Triome', type: 'land', colorsProduced: ['U', 'R', 'G']),
      CubeManaSource(
          name: 'Raugrin Triome',
          type: 'land',
          colorsProduced: ['U', 'R', 'W']),
      CubeManaSource(
          name: 'Savai Triome', type: 'land', colorsProduced: ['R', 'W', 'B']),
      CubeManaSource(
          name: 'Zagoth Triome', type: 'land', colorsProduced: ['B', 'G', 'U']),
      CubeManaSource(
          name: "Raffine's Tower",
          type: 'land',
          colorsProduced: ['W', 'U', 'B']),
      CubeManaSource(
          name: "Xander's Lounge",
          type: 'land',
          colorsProduced: ['U', 'B', 'R']),
      CubeManaSource(
          name: "Ziatora's Proving Ground",
          type: 'land',
          colorsProduced: ['B', 'R', 'G']),
      CubeManaSource(
          name: "Jetmir's Garden",
          type: 'land',
          colorsProduced: ['R', 'G', 'W']),
      CubeManaSource(
          name: "Spara's Headquarters",
          type: 'land',
          colorsProduced: ['G', 'W', 'U']),
    ];

// Default rainbow and utility lands
List<CubeManaSource> defaultUtilityLands() => const [
      CubeManaSource(
          name: 'City of Brass',
          type: 'land',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(
          name: 'Mana Confluence',
          type: 'land',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(
          name: 'Prismatic Vista',
          type: 'land',
          colorsProduced: ['W', 'U', 'B', 'R', 'G']),
      CubeManaSource(name: 'Ancient Tomb', type: 'land', colorsProduced: []),
      CubeManaSource(name: 'Strip Mine', type: 'land', colorsProduced: []),
      CubeManaSource(name: 'Wasteland', type: 'land', colorsProduced: []),
      CubeManaSource(
          name: 'Library of Alexandria', type: 'land', colorsProduced: []),
      CubeManaSource(
          name: 'Tolarian Academy', type: 'land', colorsProduced: []),
    ];

class CubeCalculatorNotifier extends StateNotifier<CubeCalculatorState> {
  CubeCalculatorNotifier()
      : super(CubeCalculatorState(
          fastManaSources: defaultFastManaSources(),
          paidManaSources: defaultPaidManaSources(),
          fetchLands: defaultFetchLands(),
          dualLands: defaultDualLands(),
          shockLands: defaultShockLands(),
          surveilLands: defaultSurveilLands(),
          triomeLands: defaultTriomeLands(),
          utilityLands: defaultUtilityLands(),
        ));

  void incrementSymbol(String manaType) {
    final newCounts = Map<String, int>.from(state.symbolCounts);
    newCounts[manaType] = (newCounts[manaType] ?? 0) + 1;
    _recalculate(state.copyWith(symbolCounts: newCounts));
  }

  void decrementSymbol(String manaType) {
    final newCounts = Map<String, int>.from(state.symbolCounts);
    final current = newCounts[manaType] ?? 0;
    if (current > 0) {
      if (current == 1) {
        newCounts.remove(manaType);
      } else {
        newCounts[manaType] = current - 1;
      }
      _recalculate(state.copyWith(symbolCounts: newCounts));
    }
  }

  void updateTargetManaSourceCount(int count) {
    if (count < 1) return;
    _recalculate(state.copyWith(targetManaSourceCount: count));
  }

  void updateDeckSize(int size) {
    if (size < 1) return;
    _recalculate(state.copyWith(deckSize: size));
  }

  void toggleFastMana(int index) {
    final sources = List<CubeManaSource>.from(state.fastManaSources);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(fastManaSources: sources));
  }

  void togglePaidMana(int index) {
    final sources = List<CubeManaSource>.from(state.paidManaSources);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(paidManaSources: sources));
  }

  void resetFastMana(int index) {
    final sources = List<CubeManaSource>.from(state.fastManaSources);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(fastManaSources: sources));
  }

  void resetPaidMana(int index) {
    final sources = List<CubeManaSource>.from(state.paidManaSources);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(paidManaSources: sources));
  }

  void toggleFetchLand(int index) {
    final sources = List<CubeManaSource>.from(state.fetchLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(fetchLands: sources));
  }

  void resetFetchLand(int index) {
    final sources = List<CubeManaSource>.from(state.fetchLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(fetchLands: sources));
  }

  void toggleDualLand(int index) {
    final sources = List<CubeManaSource>.from(state.dualLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(dualLands: sources));
  }

  void resetDualLand(int index) {
    final sources = List<CubeManaSource>.from(state.dualLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(dualLands: sources));
  }

  void toggleShockLand(int index) {
    final sources = List<CubeManaSource>.from(state.shockLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(shockLands: sources));
  }

  void resetShockLand(int index) {
    final sources = List<CubeManaSource>.from(state.shockLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(shockLands: sources));
  }

  void toggleSurveilLand(int index) {
    final sources = List<CubeManaSource>.from(state.surveilLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(surveilLands: sources));
  }

  void resetSurveilLand(int index) {
    final sources = List<CubeManaSource>.from(state.surveilLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(surveilLands: sources));
  }

  void toggleTriomeLand(int index) {
    final sources = List<CubeManaSource>.from(state.triomeLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(triomeLands: sources));
  }

  void resetTriomeLand(int index) {
    final sources = List<CubeManaSource>.from(state.triomeLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(triomeLands: sources));
  }

  void toggleUtilityLand(int index) {
    final sources = List<CubeManaSource>.from(state.utilityLands);
    sources[index] = sources[index].copyWith(count: sources[index].count + 1);
    _recalculate(state.copyWith(utilityLands: sources));
  }

  void resetUtilityLand(int index) {
    final sources = List<CubeManaSource>.from(state.utilityLands);
    sources[index] = sources[index].copyWith(count: 0);
    _recalculate(state.copyWith(utilityLands: sources));
  }

  void reset() {
    state = CubeCalculatorState(
      fastManaSources: defaultFastManaSources(),
      paidManaSources: defaultPaidManaSources(),
      fetchLands: defaultFetchLands(),
      dualLands: defaultDualLands(),
      shockLands: defaultShockLands(),
      surveilLands: defaultSurveilLands(),
      triomeLands: defaultTriomeLands(),
      utilityLands: defaultUtilityLands(),
    );
  }

  void _recalculate(CubeCalculatorState newState) {
    final symbolCounts = newState.symbolCounts;
    final activeColors = Map<String, int>.fromEntries(
      symbolCounts.entries.where((e) => e.value > 0),
    );

    if (activeColors.isEmpty) {
      state = newState.copyWith(recommendation: const CubeRecommendation());
      return;
    }

    final totalSymbols = activeColors.values.fold<int>(0, (a, b) => a + b);
    if (totalSymbols == 0) {
      state = newState.copyWith(recommendation: const CubeRecommendation());
      return;
    }

    final landsNeeded = newState.landsNeeded;
    final nonbasicCount = newState.totalNonbasicLands;
    final basicLandsNeeded = newState.basicLandsNeeded;

    // Count color-producing sources (both artifact mana AND nonbasic lands)
    final colorBonus = <String, double>{};
    for (final source in [
      ...newState.fastManaSources,
      ...newState.paidManaSources,
      ...newState.fetchLands,
      ...newState.dualLands,
      ...newState.shockLands,
      ...newState.surveilLands,
      ...newState.triomeLands,
      ...newState.utilityLands,
    ]) {
      if (source.count == 0) continue;
      if (source.colorsProduced.isEmpty) continue;
      final activeProduced = source.colorsProduced
          .where((c) => activeColors.containsKey(c))
          .toList();
      if (activeProduced.isEmpty) continue;
      for (final color in activeProduced) {
        colorBonus[color] =
            (colorBonus[color] ?? 0) + (source.count / activeProduced.length);
      }
    }

    // Proportional allocation of basic land slots
    final rawLands = <String, double>{};
    for (final entry in activeColors.entries) {
      final proportion = entry.value / totalSymbols;
      final bonus = colorBonus[entry.key] ?? 0;
      rawLands[entry.key] = (proportion * basicLandsNeeded - bonus * 0.5)
          .clamp(0, basicLandsNeeded.toDouble());
    }

    // Normalize to sum to basicLandsNeeded
    final rawSum = rawLands.values.fold<double>(0, (a, b) => a + b);
    if (rawSum > 0) {
      for (final key in rawLands.keys) {
        rawLands[key] = (rawLands[key]! / rawSum) * basicLandsNeeded;
      }
    }

    // Floor + largest remainder
    final flooredLands = <String, int>{};
    for (final entry in rawLands.entries) {
      flooredLands[entry.key] = entry.value.floor().clamp(0, basicLandsNeeded);
    }
    if (basicLandsNeeded > 0) {
      for (final color in activeColors.keys) {
        if ((flooredLands[color] ?? 0) < 1) {
          flooredLands[color] = 1;
        }
      }
    }

    int currentTotal = flooredLands.values.fold<int>(0, (a, b) => a + b);
    int deficit = basicLandsNeeded - currentTotal;

    if (deficit < 0) {
      final sorted = flooredLands.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sorted) {
        if (deficit >= 0) break;
        if (entry.value > 1) {
          flooredLands[entry.key] = entry.value - 1;
          deficit++;
        }
      }
    } else if (deficit > 0) {
      final remainders = <String, double>{};
      for (final entry in rawLands.entries) {
        remainders[entry.key] = entry.value - (flooredLands[entry.key] ?? 0);
      }
      final sorted = remainders.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      int distributed = 0;
      for (final entry in sorted) {
        if (distributed >= deficit) break;
        flooredLands[entry.key] = (flooredLands[entry.key] ?? 0) + 1;
        distributed++;
      }
    }

    // Build results
    final warnings = <String>[];
    final tips = <String>[];
    final landCounts = <CubeLandResult>[];
    final finalBasicTotal = flooredLands.values.fold<int>(0, (a, b) => a + b);
    final finalTotal = finalBasicTotal + nonbasicCount;

    for (final manaType in MtgConstants.manaTypes) {
      final count = flooredLands[manaType];
      if (count == null || count == 0) continue;

      final symbolRatio = activeColors[manaType]! / totalSymbols;
      final isSplash = symbolRatio < MtgConstants.splashThreshold;

      if (isSplash) {
        final colorName = MtgConstants.manaNames[manaType] ?? manaType;
        warnings.add(
          '$colorName is a splash (${(symbolRatio * 100).toStringAsFixed(0)}% of pips). '
          'Artifact mana may cover this.',
        );
      }

      landCounts.add(CubeLandResult(
        manaType: manaType,
        count: count,
        percentage: finalBasicTotal > 0 ? count / finalBasicTotal : 0,
        isSplash: isSplash,
      ));
    }

    if (newState.totalFastMana >= 3) {
      tips.add(
        'With ${newState.totalFastMana} fast mana sources, consider going down to '
        '${(newState.targetManaSourceCount - 1)} total mana sources.',
      );
    }

    if (newState.totalNonLandMana > 0 && landsNeeded < 14) {
      tips.add(
        'Only $landsNeeded lands needed thanks to ${newState.totalNonLandMana} artifact mana sources.',
      );
    }

    if (nonbasicCount > 0) {
      tips.add(
        '$nonbasicCount nonbasic land${nonbasicCount > 1 ? 's' : ''} replacing '
        'basic land slots. $finalBasicTotal basic lands remaining.',
      );
    }

    state = newState.copyWith(
      recommendation: CubeRecommendation(
        landCounts: landCounts,
        totalLands: finalTotal,
        basicLandCount: finalBasicTotal,
        nonbasicLandCount: nonbasicCount,
        totalManaSourcesIncludingLands: finalTotal + newState.totalNonLandMana,
        warnings: warnings,
        tips: tips,
      ),
    );
  }
}

final cubeCalculatorProvider =
    StateNotifierProvider<CubeCalculatorNotifier, CubeCalculatorState>(
  (ref) => CubeCalculatorNotifier(),
);

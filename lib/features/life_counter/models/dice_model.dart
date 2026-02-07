enum DieType { d4, d6, d8, d10, d12, d20 }

extension DieTypeExtension on DieType {
  int get maxValue {
    switch (this) {
      case DieType.d4:
        return 4;
      case DieType.d6:
        return 6;
      case DieType.d8:
        return 8;
      case DieType.d10:
        return 10;
      case DieType.d12:
        return 12;
      case DieType.d20:
        return 20;
    }
  }

  String get displayName {
    switch (this) {
      case DieType.d4:
        return 'D4';
      case DieType.d6:
        return 'D6';
      case DieType.d8:
        return 'D8';
      case DieType.d10:
        return 'D10';
      case DieType.d12:
        return 'D12';
      case DieType.d20:
        return 'D20';
    }
  }
}

class DiceRollResult {
  final DieType type;
  final int result;
  final DateTime timestamp;

  DiceRollResult({
    required this.type,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DiceState {
  final List<DiceRollResult> rollHistory;
  final DieType selectedDie;
  final int batchCount;
  final List<int> lastBatchResults;

  const DiceState({
    this.rollHistory = const [],
    this.selectedDie = DieType.d20,
    this.batchCount = 1,
    this.lastBatchResults = const [],
  });

  DiceState copyWith({
    List<DiceRollResult>? rollHistory,
    DieType? selectedDie,
    int? batchCount,
    List<int>? lastBatchResults,
  }) {
    return DiceState(
      rollHistory: rollHistory ?? this.rollHistory,
      selectedDie: selectedDie ?? this.selectedDie,
      batchCount: batchCount ?? this.batchCount,
      lastBatchResults: lastBatchResults ?? this.lastBatchResults,
    );
  }
}

class HighRollState {
  /// Player index -> their roll result. Null means not yet rolled.
  final Map<int, int?> playerRolls;
  final int? winnerIndex;
  final bool isComplete;

  const HighRollState({
    this.playerRolls = const {},
    this.winnerIndex,
    this.isComplete = false,
  });

  HighRollState copyWith({
    Map<int, int?>? playerRolls,
    int? winnerIndex,
    bool? isComplete,
    bool clearWinner = false,
  }) {
    return HighRollState(
      playerRolls: playerRolls ?? this.playerRolls,
      winnerIndex:
          clearWinner ? null : (winnerIndex ?? this.winnerIndex),
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

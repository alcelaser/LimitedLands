import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dice_model.dart';

class DiceNotifier extends StateNotifier<DiceState> {
  DiceNotifier() : super(const DiceState());

  final _random = Random();

  void setSelectedDie(DieType type) {
    state = state.copyWith(selectedDie: type);
  }

  void setBatchCount(int count) {
    state = state.copyWith(batchCount: count.clamp(1, 20));
  }

  int rollDie([DieType? type]) {
    final die = type ?? state.selectedDie;
    final result = _random.nextInt(die.maxValue) + 1;
    final rollResult = DiceRollResult(type: die, result: result);
    final history = [...state.rollHistory, rollResult];
    // Keep history capped at 50
    final trimmed = history.length > 50 ? history.sublist(history.length - 50) : history;
    state = state.copyWith(
      rollHistory: trimmed,
      lastBatchResults: [result],
    );
    return result;
  }

  List<int> batchRoll([DieType? type]) {
    final die = type ?? state.selectedDie;
    final results = <int>[];
    final history = [...state.rollHistory];
    for (int i = 0; i < state.batchCount; i++) {
      final result = _random.nextInt(die.maxValue) + 1;
      results.add(result);
      history.add(DiceRollResult(type: die, result: result));
    }
    final trimmed = history.length > 50 ? history.sublist(history.length - 50) : history;
    state = state.copyWith(
      rollHistory: trimmed,
      lastBatchResults: results,
    );
    return results;
  }

  bool flipCoin() {
    return _random.nextBool();
  }

  void clearHistory() {
    state = state.copyWith(rollHistory: [], lastBatchResults: []);
  }
}

class HighRollNotifier extends StateNotifier<HighRollState> {
  HighRollNotifier() : super(const HighRollState());

  final _random = Random();

  void initialize(int playerCount) {
    final rolls = <int, int?>{};
    for (int i = 0; i < playerCount; i++) {
      rolls[i] = null;
    }
    state = HighRollState(playerRolls: rolls);
  }

  void rollForPlayer(int playerIndex) {
    if (!state.playerRolls.containsKey(playerIndex)) return;
    if (state.playerRolls[playerIndex] != null) return; // Already rolled

    final result = _random.nextInt(20) + 1; // D20
    final rolls = Map<int, int?>.from(state.playerRolls);
    rolls[playerIndex] = result;

    // Check if all have rolled
    final allRolled = rolls.values.every((v) => v != null);
    int? winner;
    bool complete = false;

    if (allRolled) {
      // Find highest
      int maxRoll = 0;
      int maxIndex = 0;
      bool tie = false;
      for (final entry in rolls.entries) {
        if (entry.value! > maxRoll) {
          maxRoll = entry.value!;
          maxIndex = entry.key;
          tie = false;
        } else if (entry.value! == maxRoll) {
          tie = true;
        }
      }
      if (!tie) {
        winner = maxIndex;
        complete = true;
      }
      // If tie, players need to re-roll — don't set complete
    }

    state = HighRollState(
      playerRolls: rolls,
      winnerIndex: winner,
      isComplete: complete,
    );
  }

  void rollAll() {
    final rolls = <int, int?>{};
    for (final key in state.playerRolls.keys) {
      rolls[key] = _random.nextInt(20) + 1;
    }

    // Find highest
    int maxRoll = 0;
    int maxIndex = 0;
    bool tie = false;
    for (final entry in rolls.entries) {
      if (entry.value! > maxRoll) {
        maxRoll = entry.value!;
        maxIndex = entry.key;
        tie = false;
      } else if (entry.value! == maxRoll) {
        tie = true;
      }
    }

    state = HighRollState(
      playerRolls: rolls,
      winnerIndex: tie ? null : maxIndex,
      isComplete: !tie,
    );
  }

  void reset() {
    final rolls = <int, int?>{};
    for (final key in state.playerRolls.keys) {
      rolls[key] = null;
    }
    state = HighRollState(playerRolls: rolls);
  }
}

final diceProvider = StateNotifierProvider<DiceNotifier, DiceState>(
  (ref) => DiceNotifier(),
);

final highRollProvider = StateNotifierProvider<HighRollNotifier, HighRollState>(
  (ref) => HighRollNotifier(),
);

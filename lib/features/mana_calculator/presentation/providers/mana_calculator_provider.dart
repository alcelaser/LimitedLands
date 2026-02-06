import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mana_input.dart';
import '../../domain/services/mana_calculator_service.dart';
import '../../../../core/constants/mtg_constants.dart';

class ManaCalculatorState {
  final ManaInput input;
  final LandRecommendation recommendation;

  const ManaCalculatorState({
    required this.input,
    required this.recommendation,
  });

  ManaCalculatorState copyWith({
    ManaInput? input,
    LandRecommendation? recommendation,
  }) {
    return ManaCalculatorState(
      input: input ?? this.input,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}

class ManaCalculatorNotifier extends StateNotifier<ManaCalculatorState> {
  final ManaCalculatorService _calculator;

  ManaCalculatorNotifier(this._calculator)
      : super(const ManaCalculatorState(
          input: ManaInput(),
          recommendation: LandRecommendation(),
        ));

  void updateSymbolCount(String manaType, int count) {
    if (count < 0) return;
    final newCounts = Map<String, int>.from(state.input.symbolCounts);
    if (count == 0) {
      newCounts.remove(manaType);
    } else {
      newCounts[manaType] = count;
    }
    final newInput = state.input.copyWith(symbolCounts: newCounts);
    _recalculate(newInput);
  }

  void incrementSymbol(String manaType) {
    final current = state.input.symbolCounts[manaType] ?? 0;
    updateSymbolCount(manaType, current + 1);
  }

  void decrementSymbol(String manaType) {
    final current = state.input.symbolCounts[manaType] ?? 0;
    if (current > 0) {
      updateSymbolCount(manaType, current - 1);
    }
  }

  void updateDeckSize(int deckSize) {
    if (deckSize < 1) return;
    final newInput = state.input.copyWith(deckSize: deckSize);
    _recalculate(newInput);
  }

  void updateTotalLands(int totalLands) {
    if (totalLands < 0) return;
    final newInput = state.input.copyWith(totalLands: totalLands);
    _recalculate(newInput);
  }

  void applyFormatPreset(String formatName) {
    final preset = MtgConstants.formatPresets[formatName];
    if (preset == null) return;
    final newInput = state.input.copyWith(
      deckSize: preset['deckSize']!,
      totalLands: preset['landCount']!,
    );
    _recalculate(newInput);
  }

  void reset() {
    state = ManaCalculatorState(
      input: const ManaInput(),
      recommendation: _calculator.calculate(const ManaInput()),
    );
  }

  void _recalculate(ManaInput input) {
    final recommendation = _calculator.calculate(input);
    state = state.copyWith(input: input, recommendation: recommendation);
  }
}

final manaCalculatorProvider =
    StateNotifierProvider<ManaCalculatorNotifier, ManaCalculatorState>(
  (ref) => ManaCalculatorNotifier(ProportionalManaCalculator()),
);

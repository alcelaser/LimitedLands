import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/mtg_constants.dart';
import '../models/game_state_model.dart';

class GameSetupNotifier extends StateNotifier<GameConfig> {
  GameSetupNotifier() : super(const GameConfig());

  void setPlayerCount(int count) {
    final clamped = count.clamp(MtgConstants.minPlayers, MtgConstants.maxPlayers);
    state = state.copyWith(playerCount: clamped);
  }

  void setStartingLife(int life) {
    if (life < 1) return;
    state = state.copyWith(startingLife: life);
  }

  void setFormat(GameFormat format) {
    switch (format) {
      case GameFormat.standard:
        state = state.copyWith(
          format: format,
          startingLife: MtgConstants.standardStartingLife,
          partnerEnabled: false,
        );
      case GameFormat.commander:
        state = state.copyWith(
          format: format,
          startingLife: MtgConstants.commanderStartingLife,
        );
      case GameFormat.custom:
        state = state.copyWith(format: format);
    }
  }

  void togglePlanechase() {
    state = state.copyWith(planechaseEnabled: !state.planechaseEnabled);
  }

  void togglePartner() {
    state = state.copyWith(partnerEnabled: !state.partnerEnabled);
  }

  void reset() {
    state = const GameConfig();
  }
}

final gameSetupProvider =
    StateNotifierProvider<GameSetupNotifier, GameConfig>(
  (ref) => GameSetupNotifier(),
);

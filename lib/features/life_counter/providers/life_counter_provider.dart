import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerLife {
  final int life;
  final List<int> history;

  const PlayerLife({
    this.life = 20,
    this.history = const [],
  });

  PlayerLife copyWith({int? life, List<int>? history}) {
    return PlayerLife(
      life: life ?? this.life,
      history: history ?? this.history,
    );
  }
}

class LifeCounterState {
  final PlayerLife player1;
  final PlayerLife player2;
  final int startingLife;

  const LifeCounterState({
    this.player1 = const PlayerLife(),
    this.player2 = const PlayerLife(),
    this.startingLife = 20,
  });

  LifeCounterState copyWith({
    PlayerLife? player1,
    PlayerLife? player2,
    int? startingLife,
  }) {
    return LifeCounterState(
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      startingLife: startingLife ?? this.startingLife,
    );
  }
}

class LifeCounterNotifier extends StateNotifier<LifeCounterState> {
  LifeCounterNotifier() : super(const LifeCounterState());

  void changeLife(int player, int delta) {
    if (player == 1) {
      final newLife = state.player1.life + delta;
      state = state.copyWith(
        player1: state.player1.copyWith(
          life: newLife,
          history: [...state.player1.history, delta],
        ),
      );
    } else {
      final newLife = state.player2.life + delta;
      state = state.copyWith(
        player2: state.player2.copyWith(
          life: newLife,
          history: [...state.player2.history, delta],
        ),
      );
    }
  }

  void reset() {
    state = LifeCounterState(
      startingLife: state.startingLife,
      player1: PlayerLife(life: state.startingLife),
      player2: PlayerLife(life: state.startingLife),
    );
  }
}

final lifeCounterProvider =
    StateNotifierProvider<LifeCounterNotifier, LifeCounterState>(
  (ref) => LifeCounterNotifier(),
);

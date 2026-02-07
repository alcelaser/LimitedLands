import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameTimerState {
  final Duration elapsed;
  final bool isRunning;
  final Map<int, Duration> playerTurnTimes;
  final int? currentPlayerIndex;

  const GameTimerState({
    this.elapsed = Duration.zero,
    this.isRunning = false,
    this.playerTurnTimes = const {},
    this.currentPlayerIndex,
  });

  String get formattedElapsed => _formatDuration(elapsed);

  String formattedPlayerTime(int playerIndex) {
    return _formatDuration(playerTurnTimes[playerIndex] ?? Duration.zero);
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  GameTimerState copyWith({
    Duration? elapsed,
    bool? isRunning,
    Map<int, Duration>? playerTurnTimes,
    int? currentPlayerIndex,
    bool clearCurrentPlayer = false,
  }) {
    return GameTimerState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      playerTurnTimes: playerTurnTimes ?? this.playerTurnTimes,
      currentPlayerIndex:
          clearCurrentPlayer ? null : (currentPlayerIndex ?? this.currentPlayerIndex),
    );
  }
}

class GameTimerNotifier extends StateNotifier<GameTimerState> {
  GameTimerNotifier() : super(const GameTimerState());

  Timer? _timer;
  DateTime? _lastTick;

  void start(int activePlayerIndex) {
    if (state.isRunning) return;
    _lastTick = DateTime.now();
    state = state.copyWith(
      isRunning: true,
      currentPlayerIndex: activePlayerIndex,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (!state.isRunning) return;
    _accumulateSinceLastTick();
    _timer?.cancel();
    _timer = null;
    _lastTick = null;
    state = state.copyWith(isRunning: false);
  }

  void resume() {
    if (state.isRunning) return;
    _lastTick = DateTime.now();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void switchTurn(int newPlayerIndex) {
    if (state.isRunning) {
      _accumulateSinceLastTick();
      _lastTick = DateTime.now();
    }
    state = state.copyWith(currentPlayerIndex: newPlayerIndex);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _lastTick = null;
    state = const GameTimerState();
  }

  void _tick() {
    _accumulateSinceLastTick();
    _lastTick = DateTime.now();
  }

  void _accumulateSinceLastTick() {
    if (_lastTick == null) return;
    final now = DateTime.now();
    final delta = now.difference(_lastTick!);

    final newElapsed = state.elapsed + delta;

    // Add to current player's time
    final playerTimes = Map<int, Duration>.from(state.playerTurnTimes);
    final idx = state.currentPlayerIndex;
    if (idx != null) {
      playerTimes[idx] = (playerTimes[idx] ?? Duration.zero) + delta;
    }

    state = state.copyWith(
      elapsed: newElapsed,
      playerTurnTimes: playerTimes,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final gameTimerProvider =
    StateNotifierProvider<GameTimerNotifier, GameTimerState>(
  (ref) => GameTimerNotifier(),
);

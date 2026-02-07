import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/mtg_constants.dart';
import '../models/game_state_model.dart';
import '../models/player_model.dart';

const _storageKey = 'life_counter_game_v2';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState()) {
    _loadFromStorage();
  }

  static const _maxHistory = MtgConstants.maxLifeHistory;
  int _nextCounterId = 1;

  // ── Persistence ─────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      state = GameState.fromJson(json);
    } catch (_) {
      // Corrupted data: start fresh.
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  // ── Lifecycle ───────────────────────────────────────────────────

  void startGame(GameConfig config) {
    final players = List.generate(
      config.playerCount,
      (i) => PlayerState(
        id: 'p_${i + 1}',
        name: 'Player ${i + 1}',
        life: config.startingLife,
        colorIndex: i % MtgConstants.playerColors.length,
      ),
    );
    state = GameState(
      players: players,
      config: config,
      activePlayerIndex: 0,
      turnNumber: 1,
      isGameActive: true,
    );
    _saveToStorage();
  }

  void resetGame() {
    final config = state.config;
    final players = state.players
        .map((p) => PlayerState(
              id: p.id,
              name: p.name,
              life: config.startingLife,
              colorIndex: p.colorIndex,
            ))
        .toList();
    state = GameState(
      players: players,
      config: config,
      activePlayerIndex: 0,
      turnNumber: 1,
      isGameActive: true,
    );
    _saveToStorage();
  }

  void endGame() {
    state = state.copyWith(isGameActive: false);
    _saveToStorage();
  }

  // ── Life ────────────────────────────────────────────────────────

  void changeLife(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newLife = player.life + delta;
    final history = _appendHistory(player.lifeHistory, delta);
    _updatePlayer(playerIndex, player.copyWith(life: newLife, lifeHistory: history));
  }

  void setLife(int playerIndex, int value) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final delta = value - player.life;
    if (delta == 0) return;
    final history = _appendHistory(player.lifeHistory, delta);
    _updatePlayer(playerIndex, player.copyWith(life: value, lifeHistory: history));
  }

  // ── Counters ────────────────────────────────────────────────────

  void changePoison(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newVal = (player.poison + delta).clamp(0, MtgConstants.maxPoisonValue);
    _updatePlayer(playerIndex, player.copyWith(poison: newVal));
  }

  void changeExperience(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newVal = (player.experience + delta).clamp(0, MtgConstants.maxCounterValue);
    _updatePlayer(playerIndex, player.copyWith(experience: newVal));
  }

  void changeEnergy(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newVal = (player.energy + delta).clamp(0, MtgConstants.maxCounterValue);
    _updatePlayer(playerIndex, player.copyWith(energy: newVal));
  }

  void changeStormCount(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newVal = (player.stormCount + delta).clamp(0, MtgConstants.maxCounterValue);
    _updatePlayer(playerIndex, player.copyWith(stormCount: newVal));
  }

  void changeCommanderTax(int playerIndex, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final newVal = (player.commanderTax + delta).clamp(0, MtgConstants.maxCommanderTax);
    _updatePlayer(playerIndex, player.copyWith(commanderTax: newVal));
  }

  // ── Commander Damage ────────────────────────────────────────────

  void recordCommanderDamage(int targetIndex, String sourcePlayerId, int delta) {
    if (!_validIndex(targetIndex)) return;
    final player = state.players[targetIndex];
    final current = player.commanderDamageReceived[sourcePlayerId] ?? 0;
    final newVal = (current + delta).clamp(0, MtgConstants.maxCounterValue);
    final updated = Map<String, int>.from(player.commanderDamageReceived);
    updated[sourcePlayerId] = newVal;
    _updatePlayer(targetIndex, player.copyWith(commanderDamageReceived: updated));
  }

  void recordPartnerDamage(int targetIndex, String sourcePlayerId, int delta) {
    if (!_validIndex(targetIndex)) return;
    final player = state.players[targetIndex];
    final current = player.partnerDamageReceived[sourcePlayerId] ?? 0;
    final newVal = (current + delta).clamp(0, MtgConstants.maxCounterValue);
    final updated = Map<String, int>.from(player.partnerDamageReceived);
    updated[sourcePlayerId] = newVal;
    _updatePlayer(targetIndex, player.copyWith(partnerDamageReceived: updated));
  }

  // ── Mana Pool ───────────────────────────────────────────────────

  void changeMana(int playerIndex, String manaType, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final current = player.manaPool[manaType] ?? 0;
    final newVal = (current + delta).clamp(0, MtgConstants.maxCounterValue);
    final updated = Map<String, int>.from(player.manaPool);
    updated[manaType] = newVal;
    _updatePlayer(playerIndex, player.copyWith(manaPool: updated));
  }

  void clearManaPool(int playerIndex) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    _updatePlayer(playerIndex, player.copyWith(manaPool: {}));
  }

  // ── Custom Counters ─────────────────────────────────────────────

  void addCustomCounter(int playerIndex, String label) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final counter = CustomCounter(
      id: 'cc_${_nextCounterId++}',
      label: label,
    );
    _updatePlayer(
      playerIndex,
      player.copyWith(customCounters: [...player.customCounters, counter]),
    );
  }

  void changeCustomCounter(int playerIndex, String counterId, int delta) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final counters = player.customCounters.map((c) {
      if (c.id != counterId) return c;
      return c.copyWith(value: (c.value + delta).clamp(0, MtgConstants.maxCounterValue));
    }).toList();
    _updatePlayer(playerIndex, player.copyWith(customCounters: counters));
  }

  void removeCustomCounter(int playerIndex, String counterId) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    final counters = player.customCounters.where((c) => c.id != counterId).toList();
    _updatePlayer(playerIndex, player.copyWith(customCounters: counters));
  }

  // ── Player Customization ────────────────────────────────────────

  void setPlayerName(int playerIndex, String name) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    _updatePlayer(playerIndex, player.copyWith(name: name));
  }

  void setPlayerColor(int playerIndex, int colorIndex) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    _updatePlayer(playerIndex, player.copyWith(colorIndex: colorIndex));
  }

  void togglePlayerAlive(int playerIndex) {
    if (!_validIndex(playerIndex)) return;
    final player = state.players[playerIndex];
    _updatePlayer(playerIndex, player.copyWith(isAlive: !player.isAlive));
  }

  // ── Turn Management ─────────────────────────────────────────────

  void nextTurn() {
    final playerCount = state.players.length;
    if (playerCount == 0) return;

    int next = (state.activePlayerIndex + 1) % playerCount;
    // Skip dead players (max full loop to avoid infinite)
    int attempts = 0;
    while (!state.players[next].isAlive && attempts < playerCount) {
      next = (next + 1) % playerCount;
      attempts++;
    }

    state = state.copyWith(
      activePlayerIndex: next,
      turnNumber: state.turnNumber + 1,
    );
    _saveToStorage();
  }

  void setActivePlayer(int index) {
    if (!_validIndex(index)) return;
    state = state.copyWith(activePlayerIndex: index);
    _saveToStorage();
  }

  // ── Private Helpers ─────────────────────────────────────────────

  bool _validIndex(int index) => index >= 0 && index < state.players.length;

  void _updatePlayer(int index, PlayerState updated) {
    final players = List<PlayerState>.from(state.players);
    players[index] = updated;
    state = state.copyWith(players: players);
    _saveToStorage();
  }

  static List<int> _appendHistory(List<int> history, int delta) {
    final newHistory = [...history, delta];
    if (newHistory.length > _maxHistory) {
      return newHistory.sublist(newHistory.length - _maxHistory);
    }
    return newHistory;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(),
);

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limited_lands/features/life_counter/models/game_state_model.dart';
import 'package:limited_lands/features/life_counter/providers/game_provider.dart';

void main() {
  late GameNotifier notifier;

  GameConfig config2p() => const GameConfig(playerCount: 2, startingLife: 20);
  GameConfig config4p() => const GameConfig(
        playerCount: 4,
        startingLife: 40,
        format: GameFormat.commander,
        partnerEnabled: true,
      );
  GameConfig config6p() => const GameConfig(playerCount: 6, startingLife: 20);
  GameConfig config10p() => const GameConfig(playerCount: 10, startingLife: 20);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    notifier = GameNotifier();
  });

  group('GameNotifier', () {
    group('startGame', () {
      test('2 players with standard config', () {
        notifier.startGame(config2p());

        expect(notifier.state.players.length, 2);
        expect(notifier.state.isGameActive, isTrue);
        expect(notifier.state.turnNumber, 1);
        expect(notifier.state.activePlayerIndex, 0);
        expect(notifier.state.players[0].life, 20);
        expect(notifier.state.players[1].life, 20);
        expect(notifier.state.players[0].name, 'Player 1');
        expect(notifier.state.players[1].name, 'Player 2');
        expect(notifier.state.players[0].id, 'p_1');
        expect(notifier.state.players[1].id, 'p_2');
      });

      test('4 players with commander config', () {
        notifier.startGame(config4p());

        expect(notifier.state.players.length, 4);
        expect(notifier.state.config.format, GameFormat.commander);
        expect(notifier.state.config.startingLife, 40);
        for (int i = 0; i < 4; i++) {
          expect(notifier.state.players[i].life, 40);
          expect(notifier.state.players[i].colorIndex, i);
        }
      });

      test('6 players', () {
        notifier.startGame(config6p());

        expect(notifier.state.players.length, 6);
        for (final p in notifier.state.players) {
          expect(p.life, 20);
          expect(p.isAlive, isTrue);
          expect(p.poison, 0);
          expect(p.lifeHistory, isEmpty);
        }
      });

      test('10 players with color wrapping', () {
        notifier.startGame(config10p());

        expect(notifier.state.players.length, 10);
        // Colors should wrap (10 colors in palette)
        expect(notifier.state.players[0].colorIndex, 0);
        expect(notifier.state.players[9].colorIndex, 9);
      });
    });

    group('changeLife', () {
      setUp(() => notifier.startGame(config2p()));

      test('adds delta to player life', () {
        notifier.changeLife(0, 3);

        expect(notifier.state.players[0].life, 23);
        expect(notifier.state.players[1].life, 20);
      });

      test('negative delta (damage)', () {
        notifier.changeLife(0, -7);

        expect(notifier.state.players[0].life, 13);
      });

      test('appends to history', () {
        notifier.changeLife(0, 3);
        notifier.changeLife(0, -2);
        notifier.changeLife(0, 5);

        expect(notifier.state.players[0].lifeHistory, [3, -2, 5]);
        expect(notifier.state.players[0].life, 26);
      });

      test('does not affect other players', () {
        notifier.changeLife(1, 10);

        expect(notifier.state.players[0].life, 20);
        expect(notifier.state.players[1].life, 30);
      });

      test('invalid index is ignored', () {
        notifier.changeLife(-1, 5);
        notifier.changeLife(99, 5);

        expect(notifier.state.players[0].life, 20);
        expect(notifier.state.players[1].life, 20);
      });
    });

    group('setLife', () {
      setUp(() => notifier.startGame(config2p()));

      test('sets life to exact value', () {
        notifier.setLife(0, 35);

        expect(notifier.state.players[0].life, 35);
        expect(notifier.state.players[0].lifeHistory, [15]);
      });

      test('no-op when value equals current', () {
        notifier.setLife(0, 20);

        expect(notifier.state.players[0].lifeHistory, isEmpty);
      });
    });

    group('changePoison', () {
      setUp(() => notifier.startGame(config2p()));

      test('increments poison', () {
        notifier.changePoison(0, 3);

        expect(notifier.state.players[0].poison, 3);
      });

      test('clamped at 99', () {
        notifier.changePoison(0, 50);
        notifier.changePoison(0, 50);
        notifier.changePoison(0, 50);

        expect(notifier.state.players[0].poison, 99);
      });

      test('clamped at 0', () {
        notifier.changePoison(0, 2);
        notifier.changePoison(0, -5);

        expect(notifier.state.players[0].poison, 0);
      });

      test('isPoisonLethal at 10', () {
        notifier.changePoison(0, 10);

        expect(notifier.state.players[0].isPoisonLethal, isTrue);
      });

      test('not lethal at 9', () {
        notifier.changePoison(0, 9);

        expect(notifier.state.players[0].isPoisonLethal, isFalse);
      });
    });

    group('changeExperience', () {
      setUp(() => notifier.startGame(config2p()));

      test('increments experience', () {
        notifier.changeExperience(1, 4);

        expect(notifier.state.players[1].experience, 4);
      });

      test('clamped at 999', () {
        notifier.changeExperience(0, 500);
        notifier.changeExperience(0, 500);
        notifier.changeExperience(0, 500);

        expect(notifier.state.players[0].experience, 999);
      });

      test('clamped at 0', () {
        notifier.changeExperience(0, 3);
        notifier.changeExperience(0, -10);

        expect(notifier.state.players[0].experience, 0);
      });
    });

    group('changeEnergy', () {
      setUp(() => notifier.startGame(config2p()));

      test('increments energy', () {
        notifier.changeEnergy(0, 5);

        expect(notifier.state.players[0].energy, 5);
      });

      test('clamped at 999 and 0', () {
        notifier.changeEnergy(0, 1000);
        expect(notifier.state.players[0].energy, 999);

        notifier.changeEnergy(0, -2000);
        expect(notifier.state.players[0].energy, 0);
      });
    });

    group('changeStormCount', () {
      setUp(() => notifier.startGame(config2p()));

      test('increments storm count', () {
        notifier.changeStormCount(0, 7);

        expect(notifier.state.players[0].stormCount, 7);
      });

      test('clamped at 0', () {
        notifier.changeStormCount(0, -1);

        expect(notifier.state.players[0].stormCount, 0);
      });
    });

    group('changeCommanderTax', () {
      setUp(() => notifier.startGame(config2p()));

      test('increments commander tax', () {
        notifier.changeCommanderTax(0, 2);

        expect(notifier.state.players[0].commanderTax, 2);
      });

      test('clamped at 99', () {
        notifier.changeCommanderTax(0, 100);

        expect(notifier.state.players[0].commanderTax, 99);
      });
    });

    group('commander damage', () {
      setUp(() => notifier.startGame(config4p()));

      test('records damage from a specific source', () {
        notifier.recordCommanderDamage(0, 'p_2', 5);

        expect(notifier.state.players[0].commanderDamageReceived['p_2'], 5);
      });

      test('accumulates damage', () {
        notifier.recordCommanderDamage(0, 'p_2', 5);
        notifier.recordCommanderDamage(0, 'p_2', 3);

        expect(notifier.state.players[0].commanderDamageReceived['p_2'], 8);
      });

      test('tracks multiple sources independently', () {
        notifier.recordCommanderDamage(0, 'p_2', 10);
        notifier.recordCommanderDamage(0, 'p_3', 7);

        expect(notifier.state.players[0].commanderDamageReceived['p_2'], 10);
        expect(notifier.state.players[0].commanderDamageReceived['p_3'], 7);
      });

      test('lethal at 21 damage from single source', () {
        notifier.recordCommanderDamage(0, 'p_2', 21);

        expect(notifier.state.players[0].lethalCommanderSource, 'p_2');
      });

      test('not lethal at 20 damage', () {
        notifier.recordCommanderDamage(0, 'p_2', 20);

        expect(notifier.state.players[0].lethalCommanderSource, isNull);
      });

      test('partner damage tracked separately', () {
        notifier.recordPartnerDamage(0, 'p_2', 15);

        expect(notifier.state.players[0].partnerDamageReceived['p_2'], 15);
        expect(
            notifier.state.players[0].commanderDamageReceived['p_2'], isNull);
      });

      test('partner damage lethal at 21', () {
        notifier.recordPartnerDamage(0, 'p_2', 21);

        expect(notifier.state.players[0].lethalCommanderSource, 'p_2');
      });

      test('clamped at 0', () {
        notifier.recordCommanderDamage(0, 'p_2', 5);
        notifier.recordCommanderDamage(0, 'p_2', -10);

        expect(notifier.state.players[0].commanderDamageReceived['p_2'], 0);
      });
    });

    group('mana pool', () {
      setUp(() => notifier.startGame(config2p()));

      test('adds mana of a specific type', () {
        notifier.changeMana(0, 'W', 3);

        expect(notifier.state.players[0].manaPool['W'], 3);
      });

      test('accumulates mana', () {
        notifier.changeMana(0, 'U', 2);
        notifier.changeMana(0, 'U', 1);

        expect(notifier.state.players[0].manaPool['U'], 3);
      });

      test('multiple mana types tracked independently', () {
        notifier.changeMana(0, 'W', 2);
        notifier.changeMana(0, 'B', 5);
        notifier.changeMana(0, 'C', 1);

        expect(notifier.state.players[0].manaPool['W'], 2);
        expect(notifier.state.players[0].manaPool['B'], 5);
        expect(notifier.state.players[0].manaPool['C'], 1);
      });

      test('clamped at 0', () {
        notifier.changeMana(0, 'R', 2);
        notifier.changeMana(0, 'R', -5);

        expect(notifier.state.players[0].manaPool['R'], 0);
      });

      test('clearManaPool resets all mana', () {
        notifier.changeMana(0, 'W', 5);
        notifier.changeMana(0, 'U', 3);
        notifier.clearManaPool(0);

        expect(notifier.state.players[0].manaPool, isEmpty);
      });
    });

    group('custom counters', () {
      setUp(() => notifier.startGame(config2p()));

      test('adds a custom counter', () {
        notifier.addCustomCounter(0, 'Tokens');

        expect(notifier.state.players[0].customCounters.length, 1);
        expect(notifier.state.players[0].customCounters[0].label, 'Tokens');
        expect(notifier.state.players[0].customCounters[0].value, 0);
      });

      test('changes a custom counter value', () {
        notifier.addCustomCounter(0, 'Tokens');
        final counterId = notifier.state.players[0].customCounters[0].id;

        notifier.changeCustomCounter(0, counterId, 3);

        expect(notifier.state.players[0].customCounters[0].value, 3);
      });

      test('removes a custom counter', () {
        notifier.addCustomCounter(0, 'Tokens');
        notifier.addCustomCounter(0, 'Clues');
        final tokenId = notifier.state.players[0].customCounters[0].id;

        notifier.removeCustomCounter(0, tokenId);

        expect(notifier.state.players[0].customCounters.length, 1);
        expect(notifier.state.players[0].customCounters[0].label, 'Clues');
      });

      test('custom counter clamped at 0', () {
        notifier.addCustomCounter(0, 'Tokens');
        final counterId = notifier.state.players[0].customCounters[0].id;

        notifier.changeCustomCounter(0, counterId, -5);

        expect(notifier.state.players[0].customCounters[0].value, 0);
      });
    });

    group('player customization', () {
      setUp(() => notifier.startGame(config2p()));

      test('setPlayerName', () {
        notifier.setPlayerName(0, 'Alice');

        expect(notifier.state.players[0].name, 'Alice');
      });

      test('setPlayerColor', () {
        notifier.setPlayerColor(0, 5);

        expect(notifier.state.players[0].colorIndex, 5);
      });

      test('togglePlayerAlive', () {
        expect(notifier.state.players[0].isAlive, isTrue);

        notifier.togglePlayerAlive(0);
        expect(notifier.state.players[0].isAlive, isFalse);

        notifier.togglePlayerAlive(0);
        expect(notifier.state.players[0].isAlive, isTrue);
      });
    });

    group('turn management', () {
      setUp(() => notifier.startGame(config4p()));

      test('nextTurn advances to next player', () {
        expect(notifier.state.activePlayerIndex, 0);

        notifier.nextTurn();

        expect(notifier.state.activePlayerIndex, 1);
        expect(notifier.state.turnNumber, 2);
      });

      test('nextTurn wraps around', () {
        notifier.nextTurn(); // -> 1
        notifier.nextTurn(); // -> 2
        notifier.nextTurn(); // -> 3
        notifier.nextTurn(); // -> 0

        expect(notifier.state.activePlayerIndex, 0);
        expect(notifier.state.turnNumber, 5);
      });

      test('nextTurn skips dead players', () {
        notifier.togglePlayerAlive(1); // kill player 2

        notifier.nextTurn(); // should skip index 1, go to 2

        expect(notifier.state.activePlayerIndex, 2);
      });

      test('nextTurn skips multiple dead players', () {
        notifier.togglePlayerAlive(1);
        notifier.togglePlayerAlive(2);

        notifier.nextTurn(); // should skip 1 and 2, go to 3

        expect(notifier.state.activePlayerIndex, 3);
      });

      test('nextTurn wraps and skips dead', () {
        notifier.setActivePlayer(3);
        notifier.togglePlayerAlive(0); // kill player 1

        notifier.nextTurn(); // should wrap past 0, go to 1

        expect(notifier.state.activePlayerIndex, 1);
      });

      test('setActivePlayer', () {
        notifier.setActivePlayer(2);

        expect(notifier.state.activePlayerIndex, 2);
      });
    });

    group('resetGame', () {
      test('resets all player state but preserves names and colors', () {
        notifier.startGame(config4p());
        notifier.setPlayerName(0, 'Alice');
        notifier.setPlayerColor(0, 7);
        notifier.changeLife(0, -5);
        notifier.changePoison(0, 3);
        notifier.changeEnergy(1, 10);
        notifier.togglePlayerAlive(2);
        notifier.nextTurn();
        notifier.nextTurn();

        notifier.resetGame();

        expect(notifier.state.players.length, 4);
        expect(notifier.state.players[0].name, 'Alice');
        expect(notifier.state.players[0].colorIndex, 7);
        expect(notifier.state.players[0].life, 40);
        expect(notifier.state.players[0].poison, 0);
        expect(notifier.state.players[0].lifeHistory, isEmpty);
        expect(notifier.state.players[1].energy, 0);
        expect(notifier.state.players[2].isAlive, isTrue);
        expect(notifier.state.turnNumber, 1);
        expect(notifier.state.activePlayerIndex, 0);
        expect(notifier.state.isGameActive, isTrue);
      });
    });

    group('endGame', () {
      test('marks game as inactive', () {
        notifier.startGame(config2p());

        notifier.endGame();

        expect(notifier.state.isGameActive, isFalse);
      });
    });

    group('history cap', () {
      test('capped at 100 entries', () {
        notifier.startGame(config2p());

        for (int i = 1; i <= 105; i++) {
          notifier.changeLife(0, 1);
        }

        expect(notifier.state.players[0].lifeHistory.length, 100);
        expect(notifier.state.players[0].life, 20 + 105);
        expect(notifier.state.players[0].lifeHistory.every((d) => d == 1),
            isTrue);
      });
    });

    group('model serialization', () {
      test('GameState round-trips through JSON', () {
        notifier.startGame(config4p());
        notifier.setPlayerName(0, 'Alice');
        notifier.changeLife(0, -5);
        notifier.changePoison(1, 3);
        notifier.recordCommanderDamage(0, 'p_2', 10);
        notifier.changeMana(0, 'W', 3);
        notifier.addCustomCounter(0, 'Tokens');
        notifier.nextTurn();

        final json = notifier.state.toJson();
        final restored = GameState.fromJson(json);

        expect(restored.players.length, 4);
        expect(restored.players[0].name, 'Alice');
        expect(restored.players[0].life, 35);
        expect(restored.players[1].poison, 3);
        expect(restored.players[0].commanderDamageReceived['p_2'], 10);
        expect(restored.players[0].manaPool['W'], 3);
        expect(restored.players[0].customCounters.length, 1);
        expect(restored.turnNumber, 2);
        expect(restored.activePlayerIndex, 1);
        expect(restored.config.format, GameFormat.commander);
        expect(restored.config.partnerEnabled, isTrue);
      });
    });
  });
}

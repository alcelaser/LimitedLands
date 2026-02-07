import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/deck_builder/providers/deck_list_provider.dart';
import 'package:limited_lands/features/match_tracker/providers/match_tracker_provider.dart';
import 'package:limited_lands/features/card_search/providers/card_search_provider.dart';
import 'package:limited_lands/features/card_search/providers/sets_provider.dart';
import 'package:limited_lands/features/life_counter/models/player_model.dart';
import 'package:limited_lands/features/life_counter/models/game_state_model.dart';

void main() {
  // ---------------------------------------------------------------------------
  // DeckCard
  // ---------------------------------------------------------------------------
  group('DeckCard', () {
    test('toJson/fromJson round-trip with default quantity', () {
      const card = DeckCard(name: 'Lightning Bolt');
      final json = card.toJson();
      final restored = DeckCard.fromJson(json);

      expect(restored.name, equals('Lightning Bolt'));
      expect(restored.quantity, equals(1));
      expect(json, equals({'name': 'Lightning Bolt', 'quantity': 1}));
    });

    test('toJson/fromJson round-trip with custom quantity', () {
      const card = DeckCard(name: 'Island', quantity: 7);
      final json = card.toJson();
      final restored = DeckCard.fromJson(json);

      expect(restored.name, equals('Island'));
      expect(restored.quantity, equals(7));
      expect(json, equals({'name': 'Island', 'quantity': 7}));
    });

    test('fromJson with missing quantity defaults to 1', () {
      final card = DeckCard.fromJson({'name': 'Mountain'});

      expect(card.name, equals('Mountain'));
      expect(card.quantity, equals(1));
    });
  });

  // ---------------------------------------------------------------------------
  // Deck
  // ---------------------------------------------------------------------------
  group('Deck', () {
    test('toJson/fromJson round-trip with empty boards', () {
      final now = DateTime.utc(2025, 6, 15, 12, 0, 0);
      final deck = Deck(
        id: 'deck_1',
        name: 'Draft Deck',
        format: 'Limited',
        mainboard: const [],
        sideboard: const [],
        createdAt: now,
        updatedAt: now,
      );

      final json = deck.toJson();
      final restored = Deck.fromJson(json);

      expect(restored.id, equals('deck_1'));
      expect(restored.name, equals('Draft Deck'));
      expect(restored.format, equals('Limited'));
      expect(restored.mainboard, isEmpty);
      expect(restored.sideboard, isEmpty);
      expect(restored.createdAt, equals(now));
      expect(restored.updatedAt, equals(now));
    });

    test('toJson/fromJson round-trip with populated boards', () {
      final now = DateTime.utc(2025, 6, 15, 12, 0, 0);
      final deck = Deck(
        id: 'deck_2',
        name: 'Sealed Deck',
        format: 'Sealed',
        mainboard: const [
          DeckCard(name: 'Plains', quantity: 8),
          DeckCard(name: 'Banishing Light', quantity: 2),
        ],
        sideboard: const [
          DeckCard(name: 'Disenchant', quantity: 1),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final json = deck.toJson();
      final restored = Deck.fromJson(json);

      expect(restored.id, equals('deck_2'));
      expect(restored.name, equals('Sealed Deck'));
      expect(restored.format, equals('Sealed'));
      expect(restored.mainboard.length, equals(2));
      expect(restored.mainboard[0].name, equals('Plains'));
      expect(restored.mainboard[0].quantity, equals(8));
      expect(restored.mainboard[1].name, equals('Banishing Light'));
      expect(restored.mainboard[1].quantity, equals(2));
      expect(restored.sideboard.length, equals(1));
      expect(restored.sideboard[0].name, equals('Disenchant'));
      expect(restored.sideboard[0].quantity, equals(1));
    });

    test('mainboardCount and sideboardCount sum quantities', () {
      final deck = Deck(
        id: 'deck_3',
        name: 'Count Test',
        mainboard: const [
          DeckCard(name: 'Forest', quantity: 9),
          DeckCard(name: 'Llanowar Elves', quantity: 4),
          DeckCard(name: 'Giant Growth', quantity: 3),
        ],
        sideboard: const [
          DeckCard(name: 'Naturalize', quantity: 2),
          DeckCard(name: 'Plummet', quantity: 1),
        ],
      );

      expect(deck.mainboardCount, equals(16));
      expect(deck.sideboardCount, equals(3));
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.utc(2025, 1, 1);
      final deck = Deck(
        id: 'deck_4',
        name: 'Original Name',
        format: 'Draft',
        mainboard: const [DeckCard(name: 'Swamp', quantity: 8)],
        sideboard: const [DeckCard(name: 'Duress', quantity: 2)],
        createdAt: now,
      );

      final updated = deck.copyWith(name: 'Updated Name');

      expect(updated.id, equals('deck_4'));
      expect(updated.name, equals('Updated Name'));
      expect(updated.format, equals('Draft'));
      expect(updated.mainboard.length, equals(1));
      expect(updated.mainboard[0].name, equals('Swamp'));
      expect(updated.sideboard.length, equals(1));
      expect(updated.sideboard[0].name, equals('Duress'));
      expect(updated.createdAt, equals(now));
    });
  });

  // ---------------------------------------------------------------------------
  // MatchRecord
  // ---------------------------------------------------------------------------
  group('MatchRecord', () {
    test('toJson/fromJson round-trip', () {
      const match = MatchRecord(
        id: 'match_1',
        opponentName: 'Alice',
        gamesWon: 2,
        gamesLost: 1,
        isDraw: false,
        roundNumber: 3,
      );

      final json = match.toJson();
      final restored = MatchRecord.fromJson(json);

      expect(restored.id, equals('match_1'));
      expect(restored.opponentName, equals('Alice'));
      expect(restored.gamesWon, equals(2));
      expect(restored.gamesLost, equals(1));
      expect(restored.isDraw, isFalse);
      expect(restored.roundNumber, equals(3));
    });

    test('result returns win when gamesWon >= 2', () {
      const match = MatchRecord(
        id: 'match_w',
        gamesWon: 2,
        gamesLost: 0,
        roundNumber: 1,
      );
      expect(match.result, equals(MatchResult.win));

      const match3 = MatchRecord(
        id: 'match_w2',
        gamesWon: 2,
        gamesLost: 1,
        roundNumber: 1,
      );
      expect(match3.result, equals(MatchResult.win));
    });

    test('result returns loss when gamesLost >= 2', () {
      const match = MatchRecord(
        id: 'match_l',
        gamesWon: 1,
        gamesLost: 2,
        roundNumber: 1,
      );
      expect(match.result, equals(MatchResult.loss));

      const match2 = MatchRecord(
        id: 'match_l2',
        gamesWon: 0,
        gamesLost: 2,
        roundNumber: 1,
      );
      expect(match2.result, equals(MatchResult.loss));
    });

    test('result returns draw when isDraw is true', () {
      const match = MatchRecord(
        id: 'match_d',
        gamesWon: 0,
        gamesLost: 0,
        isDraw: true,
        roundNumber: 1,
      );
      expect(match.result, equals(MatchResult.draw));
    });

    test('result returns draw even when gamesWon >= 2 if isDraw is true', () {
      // isDraw is checked first in the result getter
      const match = MatchRecord(
        id: 'match_d2',
        gamesWon: 2,
        gamesLost: 0,
        isDraw: true,
        roundNumber: 1,
      );
      expect(match.result, equals(MatchResult.draw));
    });

    test('result returns inProgress otherwise', () {
      const match = MatchRecord(
        id: 'match_ip',
        gamesWon: 1,
        gamesLost: 1,
        isDraw: false,
        roundNumber: 1,
      );
      expect(match.result, equals(MatchResult.inProgress));

      const match2 = MatchRecord(
        id: 'match_ip2',
        gamesWon: 0,
        gamesLost: 0,
        isDraw: false,
        roundNumber: 1,
      );
      expect(match2.result, equals(MatchResult.inProgress));
    });

    test('isComplete is true for win, loss, and draw', () {
      const win = MatchRecord(
        id: 'c_w', gamesWon: 2, gamesLost: 0, roundNumber: 1,
      );
      const loss = MatchRecord(
        id: 'c_l', gamesWon: 0, gamesLost: 2, roundNumber: 1,
      );
      const draw = MatchRecord(
        id: 'c_d', isDraw: true, roundNumber: 1,
      );

      expect(win.isComplete, isTrue);
      expect(loss.isComplete, isTrue);
      expect(draw.isComplete, isTrue);
    });

    test('isComplete is false for inProgress', () {
      const match = MatchRecord(
        id: 'c_ip', gamesWon: 1, gamesLost: 0, roundNumber: 1,
      );
      expect(match.isComplete, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Event
  // ---------------------------------------------------------------------------
  group('Event', () {
    test('toJson/fromJson round-trip', () {
      final now = DateTime.utc(2025, 3, 20, 18, 30, 0);
      final event = Event(
        id: 'event_1',
        name: 'FNM Draft',
        format: 'Draft',
        matches: const [
          MatchRecord(
            id: 'match_1',
            opponentName: 'Bob',
            gamesWon: 2,
            gamesLost: 1,
            roundNumber: 1,
          ),
          MatchRecord(
            id: 'match_2',
            opponentName: 'Carol',
            gamesWon: 0,
            gamesLost: 2,
            roundNumber: 2,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      );

      final json = event.toJson();
      final restored = Event.fromJson(json);

      expect(restored.id, equals('event_1'));
      expect(restored.name, equals('FNM Draft'));
      expect(restored.format, equals('Draft'));
      expect(restored.matches.length, equals(2));
      expect(restored.matches[0].opponentName, equals('Bob'));
      expect(restored.matches[0].gamesWon, equals(2));
      expect(restored.matches[1].opponentName, equals('Carol'));
      expect(restored.matches[1].gamesLost, equals(2));
      expect(restored.createdAt, equals(now));
      expect(restored.updatedAt, equals(now));
    });

    test('record computed correctly without draws', () {
      final event = Event(
        id: 'event_r1',
        name: 'Test',
        matches: const [
          MatchRecord(id: 'm1', gamesWon: 2, gamesLost: 0, roundNumber: 1),
          MatchRecord(id: 'm2', gamesWon: 2, gamesLost: 1, roundNumber: 2),
          MatchRecord(id: 'm3', gamesWon: 0, gamesLost: 2, roundNumber: 3),
        ],
      );

      expect(event.record, equals('2-1'));
    });

    test('record computed correctly with draws', () {
      final event = Event(
        id: 'event_r2',
        name: 'Test',
        matches: const [
          MatchRecord(id: 'm1', gamesWon: 2, gamesLost: 0, roundNumber: 1),
          MatchRecord(id: 'm2', isDraw: true, roundNumber: 2),
          MatchRecord(id: 'm3', gamesWon: 0, gamesLost: 2, roundNumber: 3),
        ],
      );

      expect(event.record, equals('1-1-1'));
    });

    test('wins, losses, and draws count correctly', () {
      final event = Event(
        id: 'event_c',
        name: 'Counter Test',
        matches: const [
          MatchRecord(id: 'm1', gamesWon: 2, gamesLost: 0, roundNumber: 1),
          MatchRecord(id: 'm2', gamesWon: 2, gamesLost: 1, roundNumber: 2),
          MatchRecord(id: 'm3', gamesWon: 0, gamesLost: 2, roundNumber: 3),
          MatchRecord(id: 'm4', isDraw: true, roundNumber: 4),
          MatchRecord(id: 'm5', gamesWon: 1, gamesLost: 0, roundNumber: 5),
        ],
      );

      expect(event.wins, equals(2));
      expect(event.losses, equals(1));
      expect(event.draws, equals(1));
      expect(event.matchCount, equals(5));
      expect(event.completedCount, equals(4));
    });
  });

  // ---------------------------------------------------------------------------
  // CardRating
  // ---------------------------------------------------------------------------
  group('CardRating', () {
    test('fromJson with all fields present', () {
      final card = CardRating.fromJson({
        'name': 'Sheoldred, the Apocalypse',
        'color': 'B',
        'rarity': 'mythic',
        'ever_drawn_win_rate': 0.645,
        'avg_pick': 1.2,
        'drawn_improvement_win_rate': 0.12,
        'play_rate': 0.98,
        'url': 'https://example.com/card.png',
      });

      expect(card.name, equals('Sheoldred, the Apocalypse'));
      expect(card.color, equals('B'));
      expect(card.rarity, equals('mythic'));
      expect(card.gihWinRate, closeTo(0.645, 0.001));
      expect(card.avgPick, closeTo(1.2, 0.001));
      expect(card.iwd, closeTo(0.12, 0.001));
      expect(card.playRate, closeTo(0.98, 0.001));
      expect(card.imageUrl, equals('https://example.com/card.png'));
    });

    test('fromJson with null optional fields', () {
      final card = CardRating.fromJson({
        'name': 'Basic Land',
        'color': '',
        'rarity': 'common',
        'ever_drawn_win_rate': null,
        'avg_pick': null,
        'drawn_improvement_win_rate': null,
        'play_rate': null,
        'url': null,
      });

      expect(card.name, equals('Basic Land'));
      expect(card.color, equals(''));
      expect(card.rarity, equals('common'));
      expect(card.gihWinRate, isNull);
      expect(card.avgPick, isNull);
      expect(card.iwd, isNull);
      expect(card.playRate, isNull);
      expect(card.imageUrl, isNull);
    });

    test('fromJson with completely missing optional fields', () {
      final card = CardRating.fromJson({
        'name': 'Mystery Card',
        'color': 'W',
        'rarity': 'rare',
      });

      expect(card.name, equals('Mystery Card'));
      expect(card.gihWinRate, isNull);
      expect(card.avgPick, isNull);
      expect(card.iwd, isNull);
      expect(card.playRate, isNull);
      expect(card.imageUrl, isNull);
    });

    test('fromJson parses int values as double', () {
      final card = CardRating.fromJson({
        'name': 'Int Test Card',
        'color': 'R',
        'rarity': 'uncommon',
        'ever_drawn_win_rate': 1,
        'avg_pick': 5,
        'drawn_improvement_win_rate': 0,
        'play_rate': 1,
      });

      expect(card.gihWinRate, isA<double>());
      expect(card.gihWinRate, equals(1.0));
      expect(card.avgPick, isA<double>());
      expect(card.avgPick, equals(5.0));
      expect(card.iwd, isA<double>());
      expect(card.iwd, equals(0.0));
      expect(card.playRate, isA<double>());
      expect(card.playRate, equals(1.0));
    });

    test('fromJson parses String values as double', () {
      final card = CardRating.fromJson({
        'name': 'String Test Card',
        'color': 'U',
        'rarity': 'common',
        'ever_drawn_win_rate': '0.55',
        'avg_pick': '3.7',
        'drawn_improvement_win_rate': '0.02',
        'play_rate': '0.80',
      });

      expect(card.gihWinRate, closeTo(0.55, 0.001));
      expect(card.avgPick, closeTo(3.7, 0.001));
      expect(card.iwd, closeTo(0.02, 0.001));
      expect(card.playRate, closeTo(0.80, 0.001));
    });

    test('fromJson defaults name to Unknown when missing', () {
      final card = CardRating.fromJson({
        'color': 'G',
        'rarity': 'common',
      });

      expect(card.name, equals('Unknown'));
    });
  });

  // ---------------------------------------------------------------------------
  // MtgSet
  // ---------------------------------------------------------------------------
  group('MtgSet', () {
    test('fromJson uppercases code', () {
      final set = MtgSet.fromJson({
        'code': 'mkm',
        'name': 'Murders at Karlov Manor',
        'set_type': 'expansion',
        'released_at': '2024-02-09',
      });

      expect(set.code, equals('MKM'));
      expect(set.name, equals('Murders at Karlov Manor'));
      expect(set.setType, equals('expansion'));
      expect(set.releasedAt, equals('2024-02-09'));
    });

    test('fromJson with already uppercase code', () {
      final set = MtgSet.fromJson({
        'code': 'OTJ',
        'name': 'Outlaws of Thunder Junction',
        'set_type': 'expansion',
        'released_at': '2024-04-19',
      });

      expect(set.code, equals('OTJ'));
    });

    test('fromJson with missing optional fields', () {
      final set = MtgSet.fromJson({
        'code': 'fdn',
        'name': 'Foundations',
        'set_type': 'core',
      });

      expect(set.code, equals('FDN'));
      expect(set.name, equals('Foundations'));
      expect(set.setType, equals('core'));
      expect(set.releasedAt, isNull);
    });

    test('fromJson defaults name and setType to empty string when null', () {
      final set = MtgSet.fromJson({
        'code': 'xyz',
      });

      expect(set.code, equals('XYZ'));
      expect(set.name, equals(''));
      expect(set.setType, equals(''));
      expect(set.releasedAt, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // PlayerState & CustomCounter
  // ---------------------------------------------------------------------------
  group('PlayerState', () {
    test('default values', () {
      const player = PlayerState(id: 'p_1');

      expect(player.id, equals('p_1'));
      expect(player.name, equals(''));
      expect(player.life, equals(20));
      expect(player.poison, equals(0));
      expect(player.experience, equals(0));
      expect(player.energy, equals(0));
      expect(player.stormCount, equals(0));
      expect(player.commanderTax, equals(0));
      expect(player.commanderDamageReceived, isEmpty);
      expect(player.partnerDamageReceived, isEmpty);
      expect(player.manaPool, isEmpty);
      expect(player.customCounters, isEmpty);
      expect(player.colorIndex, equals(0));
      expect(player.isAlive, isTrue);
      expect(player.lifeHistory, isEmpty);
    });

    test('copyWith changes specified fields only', () {
      const original = PlayerState(
        id: 'p_1',
        name: 'Alice',
        life: 20,
        poison: 3,
      );

      final updated = original.copyWith(life: 17, poison: 5);

      expect(updated.id, equals('p_1'));
      expect(updated.name, equals('Alice'));
      expect(updated.life, equals(17));
      expect(updated.poison, equals(5));
      expect(updated.experience, equals(0));
    });

    test('toJson/fromJson round-trip', () {
      const player = PlayerState(
        id: 'p_1',
        name: 'Bob',
        life: 15,
        poison: 3,
        experience: 2,
        energy: 5,
        stormCount: 1,
        commanderTax: 4,
        colorIndex: 3,
        isAlive: true,
        lifeHistory: [5, -2, -3],
      );

      final json = player.toJson();
      final restored = PlayerState.fromJson(json);

      expect(restored.id, equals('p_1'));
      expect(restored.name, equals('Bob'));
      expect(restored.life, equals(15));
      expect(restored.poison, equals(3));
      expect(restored.experience, equals(2));
      expect(restored.energy, equals(5));
      expect(restored.stormCount, equals(1));
      expect(restored.commanderTax, equals(4));
      expect(restored.colorIndex, equals(3));
      expect(restored.isAlive, isTrue);
      expect(restored.lifeHistory, equals([5, -2, -3]));
    });

    test('lethalCommanderSource returns source at 21', () {
      const player = PlayerState(
        id: 'p_1',
        commanderDamageReceived: {'p_2': 21},
      );

      expect(player.lethalCommanderSource, equals('p_2'));
    });

    test('lethalCommanderSource returns null below 21', () {
      const player = PlayerState(
        id: 'p_1',
        commanderDamageReceived: {'p_2': 20},
      );

      expect(player.lethalCommanderSource, isNull);
    });

    test('isPoisonLethal at 10', () {
      const player = PlayerState(id: 'p_1', poison: 10);
      expect(player.isPoisonLethal, isTrue);
    });

    test('isPoisonLethal false at 9', () {
      const player = PlayerState(id: 'p_1', poison: 9);
      expect(player.isPoisonLethal, isFalse);
    });
  });

  group('CustomCounter', () {
    test('default value is 0', () {
      const counter = CustomCounter(id: 'cc_1', label: 'Tokens');
      expect(counter.value, equals(0));
    });

    test('toJson/fromJson round-trip', () {
      const counter = CustomCounter(id: 'cc_1', label: 'Clues', value: 3);
      final json = counter.toJson();
      final restored = CustomCounter.fromJson(json);

      expect(restored.id, equals('cc_1'));
      expect(restored.label, equals('Clues'));
      expect(restored.value, equals(3));
    });

    test('copyWith', () {
      const counter = CustomCounter(id: 'cc_1', label: 'Tokens', value: 5);
      final updated = counter.copyWith(value: 8);

      expect(updated.id, equals('cc_1'));
      expect(updated.label, equals('Tokens'));
      expect(updated.value, equals(8));
    });
  });

  group('GameConfig', () {
    test('default values', () {
      const config = GameConfig();

      expect(config.playerCount, equals(2));
      expect(config.startingLife, equals(20));
      expect(config.format, equals(GameFormat.standard));
      expect(config.planechaseEnabled, isFalse);
      expect(config.partnerEnabled, isFalse);
    });

    test('toJson/fromJson round-trip', () {
      const config = GameConfig(
        playerCount: 4,
        startingLife: 40,
        format: GameFormat.commander,
        planechaseEnabled: true,
        partnerEnabled: true,
      );

      final json = config.toJson();
      final restored = GameConfig.fromJson(json);

      expect(restored.playerCount, equals(4));
      expect(restored.startingLife, equals(40));
      expect(restored.format, equals(GameFormat.commander));
      expect(restored.planechaseEnabled, isTrue);
      expect(restored.partnerEnabled, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limited_lands/features/deck_builder/providers/deck_list_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<DeckListNotifier> createNotifier() async {
    final notifier = DeckListNotifier();
    // Allow the async _loadFromStorage to complete.
    await Future.delayed(Duration.zero);
    return notifier;
  }

  group('DeckListNotifier', () {
    group('createDeck', () {
      test('adds deck with correct defaults', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        expect(notifier.state.decks.length, 1);
        expect(deck.name, 'New Deck');
        expect(deck.format, 'Limited');
        expect(deck.mainboard, isEmpty);
        expect(deck.sideboard, isEmpty);
        expect(deck.id, 'deck_1');
      });

      test('with custom name and format', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck(name: 'Draft Night', format: 'Sealed');

        expect(deck.name, 'Draft Night');
        expect(deck.format, 'Sealed');
        expect(notifier.state.decks.length, 1);
        expect(notifier.state.decks.first.name, 'Draft Night');
        expect(notifier.state.decks.first.format, 'Sealed');
      });

      test('generates unique incrementing IDs', () async {
        final notifier = await createNotifier();
        final deck1 = notifier.createDeck(name: 'First');
        final deck2 = notifier.createDeck(name: 'Second');
        final deck3 = notifier.createDeck(name: 'Third');

        expect(deck1.id, 'deck_1');
        expect(deck2.id, 'deck_2');
        expect(deck3.id, 'deck_3');
        expect(notifier.state.decks.length, 3);
      });
    });

    group('deleteDeck', () {
      test('removes the correct deck', () async {
        final notifier = await createNotifier();
        notifier.createDeck(name: 'Keep');
        final deck2 = notifier.createDeck(name: 'Remove');
        notifier.createDeck(name: 'Also Keep');

        notifier.deleteDeck(deck2.id);

        expect(notifier.state.decks.length, 2);
        expect(notifier.state.decks.map((d) => d.name).toList(),
            ['Keep', 'Also Keep']);
      });

      test('with unknown ID is a no-op', () async {
        final notifier = await createNotifier();
        notifier.createDeck(name: 'Existing');

        notifier.deleteDeck('deck_999');

        expect(notifier.state.decks.length, 1);
        expect(notifier.state.decks.first.name, 'Existing');
      });
    });

    group('addCardToMainboard', () {
      test('adds new card with quantity 1', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');

        final updated = notifier.state.decks.first;
        expect(updated.mainboard.length, 1);
        expect(updated.mainboard.first.name, 'Lightning Bolt');
        expect(updated.mainboard.first.quantity, 1);
      });

      test('increments existing card quantity (case-insensitive)', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');
        notifier.addCardToMainboard(deck.id, 'lightning bolt');
        notifier.addCardToMainboard(deck.id, 'LIGHTNING BOLT');

        final updated = notifier.state.decks.first;
        expect(updated.mainboard.length, 1);
        expect(updated.mainboard.first.quantity, 3);
      });

      test('with invalid deckId is a no-op', () async {
        final notifier = await createNotifier();
        notifier.createDeck();

        // Should not throw or change state.
        notifier.addCardToMainboard('nonexistent', 'Lightning Bolt');

        final deck = notifier.state.decks.first;
        expect(deck.mainboard, isEmpty);
      });
    });

    group('addCardToSideboard', () {
      test('works same as mainboard', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToSideboard(deck.id, 'Negate');
        notifier.addCardToSideboard(deck.id, 'negate');

        final updated = notifier.state.decks.first;
        expect(updated.sideboard.length, 1);
        expect(updated.sideboard.first.name, 'Negate');
        expect(updated.sideboard.first.quantity, 2);
        // Mainboard should remain untouched.
        expect(updated.mainboard, isEmpty);
      });
    });

    group('removeCardFromMainboard', () {
      test('decrements quantity when greater than 1', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');
        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');
        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');

        // Quantity is now 3; removing once should decrement to 2.
        notifier.removeCardFromMainboard(deck.id, 0);

        final updated = notifier.state.decks.first;
        expect(updated.mainboard.length, 1);
        expect(updated.mainboard.first.quantity, 2);
      });

      test('removes card when quantity reaches 0', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');

        // Quantity is 1; removing once should remove the card entirely.
        notifier.removeCardFromMainboard(deck.id, 0);

        final updated = notifier.state.decks.first;
        expect(updated.mainboard, isEmpty);
      });

      test('with invalid deckId is a no-op', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();
        notifier.addCardToMainboard(deck.id, 'Lightning Bolt');

        // Should not throw or change state.
        notifier.removeCardFromMainboard('nonexistent', 0);

        final updated = notifier.state.decks.first;
        expect(updated.mainboard.length, 1);
        expect(updated.mainboard.first.quantity, 1);
      });
    });

    group('removeCardFromSideboard', () {
      test('works same as mainboard', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck();

        notifier.addCardToSideboard(deck.id, 'Negate');
        notifier.addCardToSideboard(deck.id, 'Negate');

        notifier.removeCardFromSideboard(deck.id, 0);

        final updated = notifier.state.decks.first;
        expect(updated.sideboard.length, 1);
        expect(updated.sideboard.first.quantity, 1);

        notifier.removeCardFromSideboard(deck.id, 0);

        final finalState = notifier.state.decks.first;
        expect(finalState.sideboard, isEmpty);
      });
    });

    group('updateDeck', () {
      test('replaces matching deck in state', () async {
        final notifier = await createNotifier();
        final deck = notifier.createDeck(name: 'Old Name');
        final updated = deck.copyWith(name: 'New Name');

        notifier.updateDeck(updated);

        expect(notifier.state.decks.length, 1);
        expect(notifier.state.decks.first.name, 'New Name');
      });
    });
  });
}

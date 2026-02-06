import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeckCard {
  final String name;
  final int quantity;

  const DeckCard({required this.name, this.quantity = 1});

  DeckCard copyWith({String? name, int? quantity}) {
    return DeckCard(name: name ?? this.name, quantity: quantity ?? this.quantity);
  }
}

class Deck {
  final String id;
  final String name;
  final String format;
  final List<DeckCard> mainboard;
  final List<DeckCard> sideboard;
  final DateTime createdAt;
  final DateTime updatedAt;

  Deck({
    required this.id,
    required this.name,
    this.format = 'Limited',
    this.mainboard = const [],
    this.sideboard = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get mainboardCount =>
      mainboard.fold<int>(0, (sum, c) => sum + c.quantity);
  int get sideboardCount =>
      sideboard.fold<int>(0, (sum, c) => sum + c.quantity);

  Deck copyWith({
    String? name,
    String? format,
    List<DeckCard>? mainboard,
    List<DeckCard>? sideboard,
    DateTime? updatedAt,
  }) {
    return Deck(
      id: id,
      name: name ?? this.name,
      format: format ?? this.format,
      mainboard: mainboard ?? this.mainboard,
      sideboard: sideboard ?? this.sideboard,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class DeckListState {
  final List<Deck> decks;

  const DeckListState({this.decks = const []});
}

class DeckListNotifier extends StateNotifier<DeckListState> {
  DeckListNotifier() : super(const DeckListState());

  int _nextId = 1;

  Deck createDeck({String name = 'New Deck', String format = 'Limited'}) {
    final deck = Deck(
      id: 'deck_${_nextId++}',
      name: name,
      format: format,
    );
    state = DeckListState(decks: [...state.decks, deck]);
    return deck;
  }

  void deleteDeck(String id) {
    state = DeckListState(
      decks: state.decks.where((d) => d.id != id).toList(),
    );
  }

  void updateDeck(Deck updated) {
    state = DeckListState(
      decks: state.decks.map((d) => d.id == updated.id ? updated : d).toList(),
    );
  }

  void addCardToMainboard(String deckId, String cardName) {
    final deck = state.decks.firstWhere((d) => d.id == deckId);
    final existing = deck.mainboard.indexWhere(
        (c) => c.name.toLowerCase() == cardName.toLowerCase());
    List<DeckCard> newMainboard;
    if (existing >= 0) {
      newMainboard = List.from(deck.mainboard);
      newMainboard[existing] = newMainboard[existing]
          .copyWith(quantity: newMainboard[existing].quantity + 1);
    } else {
      newMainboard = [...deck.mainboard, DeckCard(name: cardName)];
    }
    updateDeck(deck.copyWith(mainboard: newMainboard));
  }

  void addCardToSideboard(String deckId, String cardName) {
    final deck = state.decks.firstWhere((d) => d.id == deckId);
    final existing = deck.sideboard.indexWhere(
        (c) => c.name.toLowerCase() == cardName.toLowerCase());
    List<DeckCard> newSideboard;
    if (existing >= 0) {
      newSideboard = List.from(deck.sideboard);
      newSideboard[existing] = newSideboard[existing]
          .copyWith(quantity: newSideboard[existing].quantity + 1);
    } else {
      newSideboard = [...deck.sideboard, DeckCard(name: cardName)];
    }
    updateDeck(deck.copyWith(sideboard: newSideboard));
  }

  void removeCardFromMainboard(String deckId, int index) {
    final deck = state.decks.firstWhere((d) => d.id == deckId);
    final card = deck.mainboard[index];
    List<DeckCard> newMainboard = List.from(deck.mainboard);
    if (card.quantity > 1) {
      newMainboard[index] = card.copyWith(quantity: card.quantity - 1);
    } else {
      newMainboard.removeAt(index);
    }
    updateDeck(deck.copyWith(mainboard: newMainboard));
  }

  void removeCardFromSideboard(String deckId, int index) {
    final deck = state.decks.firstWhere((d) => d.id == deckId);
    final card = deck.sideboard[index];
    List<DeckCard> newSideboard = List.from(deck.sideboard);
    if (card.quantity > 1) {
      newSideboard[index] = card.copyWith(quantity: card.quantity - 1);
    } else {
      newSideboard.removeAt(index);
    }
    updateDeck(deck.copyWith(sideboard: newSideboard));
  }
}

final deckListProvider =
    StateNotifierProvider<DeckListNotifier, DeckListState>(
  (ref) => DeckListNotifier(),
);

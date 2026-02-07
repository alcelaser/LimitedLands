import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/card_search/providers/card_search_provider.dart';

void main() {
  late CardSearchNotifier notifier;

  setUp(() {
    notifier = CardSearchNotifier();
  });

  group('CardSearchNotifier initial state', () {
    test('has correct defaults', () {
      expect(notifier.state.expansion, 'FDN');
      expect(notifier.state.format, 'PremierDraft');
      expect(notifier.state.allCards, isEmpty);
      expect(notifier.state.searchQuery, '');
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      expect(notifier.state.sortBy, 'gihWr');
      expect(notifier.state.sortAscending, false);
    });
  });

  group('setExpansion', () {
    test('uppercases input', () {
      notifier.setExpansion('fdn');
      expect(notifier.state.expansion, 'FDN');
    });

    test('handles mixed case', () {
      notifier.setExpansion('dSk');
      expect(notifier.state.expansion, 'DSK');
    });
  });

  group('setFormat', () {
    test('updates format', () {
      notifier.setFormat('QuickDraft');
      expect(notifier.state.format, 'QuickDraft');
    });
  });

  group('setSearchQuery', () {
    test('updates search query', () {
      notifier.setSearchQuery('bolt');
      expect(notifier.state.searchQuery, 'bolt');
    });
  });

  group('setSortBy', () {
    test('sets new sort key with default ascending', () {
      notifier.setSortBy('name');
      expect(notifier.state.sortBy, 'name');
      expect(notifier.state.sortAscending, true);
    });

    test('ata defaults to ascending', () {
      notifier.setSortBy('ata');
      expect(notifier.state.sortBy, 'ata');
      expect(notifier.state.sortAscending, true);
    });

    test('gihWr defaults to descending', () {
      // Start from name ascending
      notifier.setSortBy('name');
      notifier.setSortBy('gihWr');
      expect(notifier.state.sortBy, 'gihWr');
      expect(notifier.state.sortAscending, false);
    });

    test('toggles ascending when same key tapped', () {
      notifier.setSortBy('name');
      expect(notifier.state.sortAscending, true);
      notifier.setSortBy('name');
      expect(notifier.state.sortAscending, false);
      notifier.setSortBy('name');
      expect(notifier.state.sortAscending, true);
    });
  });

  group('CardSearchState.filteredCards', () {
    final cards = [
      const CardRating(
        name: 'Lightning Bolt',
        color: 'R',
        rarity: 'common',
        gihWinRate: 0.58,
        avgPick: 2.1,
      ),
      const CardRating(
        name: 'Counterspell',
        color: 'U',
        rarity: 'uncommon',
        gihWinRate: 0.55,
        avgPick: 3.5,
      ),
      const CardRating(
        name: 'Dark Ritual',
        color: 'B',
        rarity: 'common',
        gihWinRate: 0.52,
        avgPick: 5.0,
      ),
      const CardRating(
        name: 'Bolt of Light',
        color: 'W',
        rarity: 'rare',
        gihWinRate: null,
        avgPick: null,
      ),
    ];

    test('returns all cards when no search query', () {
      final state = CardSearchState(allCards: cards);
      expect(state.filteredCards.length, 4);
    });

    test('filters by name case-insensitively', () {
      final state = CardSearchState(allCards: cards, searchQuery: 'bolt');
      final filtered = state.filteredCards;
      expect(filtered.length, 2);
      expect(filtered.map((c) => c.name),
          containsAll(['Lightning Bolt', 'Bolt of Light']));
    });

    test('sorts by gihWr descending by default', () {
      final state = CardSearchState(allCards: cards);
      final filtered = state.filteredCards;
      // Descending: 0.58, 0.55, 0.52, null(-1)
      expect(filtered[0].name, 'Lightning Bolt');
      expect(filtered[1].name, 'Counterspell');
      expect(filtered[2].name, 'Dark Ritual');
      expect(filtered[3].name, 'Bolt of Light');
    });

    test('sorts by gihWr ascending', () {
      final state = CardSearchState(
          allCards: cards, sortBy: 'gihWr', sortAscending: true);
      final filtered = state.filteredCards;
      // Ascending: null(-1), 0.52, 0.55, 0.58
      expect(filtered[0].name, 'Bolt of Light');
      expect(filtered[3].name, 'Lightning Bolt');
    });

    test('sorts by ata ascending', () {
      final state =
          CardSearchState(allCards: cards, sortBy: 'ata', sortAscending: true);
      final filtered = state.filteredCards;
      // Ascending: 2.1, 3.5, 5.0, null(99)
      expect(filtered[0].name, 'Lightning Bolt');
      expect(filtered[1].name, 'Counterspell');
      expect(filtered[2].name, 'Dark Ritual');
      expect(filtered[3].name, 'Bolt of Light');
    });

    test('sorts by name ascending', () {
      final state = CardSearchState(
          allCards: cards, sortBy: 'name', sortAscending: true);
      final filtered = state.filteredCards;
      expect(filtered[0].name, 'Bolt of Light');
      expect(filtered[1].name, 'Counterspell');
      expect(filtered[2].name, 'Dark Ritual');
      expect(filtered[3].name, 'Lightning Bolt');
    });

    test('sorts by name descending', () {
      final state = CardSearchState(
          allCards: cards, sortBy: 'name', sortAscending: false);
      final filtered = state.filteredCards;
      expect(filtered[0].name, 'Lightning Bolt');
      expect(filtered[3].name, 'Bolt of Light');
    });

    test('caches result on repeated access', () {
      final state = CardSearchState(allCards: cards);
      final first = state.filteredCards;
      final second = state.filteredCards;
      expect(identical(first, second), true);
    });
  });

  group('CardSearchState.copyWith error handling', () {
    test('clearError removes error', () {
      final state = CardSearchState(error: 'some error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('error persists without clearError', () {
      final state = CardSearchState(error: 'some error');
      final updated = state.copyWith(isLoading: true);
      expect(updated.error, 'some error');
    });

    test('new error replaces old error', () {
      final state = CardSearchState(error: 'old error');
      final updated = state.copyWith(error: 'new error');
      expect(updated.error, 'new error');
    });

    test('clearError takes precedence over error param', () {
      final state = CardSearchState(error: 'old error');
      final updated = state.copyWith(error: 'new error', clearError: true);
      expect(updated.error, isNull);
    });
  });

  group('fetchCards', () {
    test('sets error when expansion is empty', () async {
      notifier.setExpansion('');
      await notifier.fetchCards();
      expect(notifier.state.error, 'Enter a set code');
      expect(notifier.state.isLoading, false);
    });
  });
}

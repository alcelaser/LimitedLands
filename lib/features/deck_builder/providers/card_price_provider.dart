import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/scryfall_image_service.dart';

class CardPriceState {
  final Map<String, double?> prices;
  final bool isLoading;

  const CardPriceState({
    this.prices = const {},
    this.isLoading = false,
  });

  CardPriceState copyWith({
    Map<String, double?>? prices,
    bool? isLoading,
  }) {
    return CardPriceState(
      prices: prices ?? this.prices,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double? priceFor(String cardName) => prices[cardName.toLowerCase()];
}

class CardPriceNotifier extends StateNotifier<CardPriceState> {
  CardPriceNotifier() : super(const CardPriceState());

  Future<void> fetchPricesForCards(List<String> cardNames) async {
    if (cardNames.isEmpty) return;

    // Filter out names we already have cached
    final uncached = cardNames
        .where((name) => !state.prices.containsKey(name.toLowerCase()))
        .toList();

    if (uncached.isEmpty) return;

    state = state.copyWith(isLoading: true);

    final newPrices = await ScryfallImageService.fetchPrices(uncached);

    // Merge with existing cache
    final merged = Map<String, double?>.from(state.prices);
    merged.addAll(newPrices);

    // Mark cards that weren't found as null so we don't re-fetch
    for (final name in uncached) {
      if (!merged.containsKey(name.toLowerCase())) {
        merged[name.toLowerCase()] = null;
      }
    }

    state = CardPriceState(prices: merged, isLoading: false);
  }

  void clear() {
    state = const CardPriceState();
  }
}

final cardPriceProvider =
    StateNotifierProvider<CardPriceNotifier, CardPriceState>(
  (ref) => CardPriceNotifier(),
);

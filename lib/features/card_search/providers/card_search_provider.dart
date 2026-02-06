import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class CardRating {
  final String name;
  final String color;
  final String rarity;
  final double? gihWinRate;
  final double? avgPick;
  final double? iwd;
  final double? playRate;
  final String? imageUrl;

  const CardRating({
    required this.name,
    required this.color,
    required this.rarity,
    this.gihWinRate,
    this.avgPick,
    this.iwd,
    this.playRate,
    this.imageUrl,
  });

  factory CardRating.fromJson(Map<String, dynamic> json) {
    return CardRating(
      name: json['name'] as String? ?? 'Unknown',
      color: json['color'] as String? ?? '',
      rarity: json['rarity'] as String? ?? '',
      gihWinRate: _parseDouble(json['ever_drawn_win_rate']),
      avgPick: _parseDouble(json['avg_pick']),
      iwd: _parseDouble(json['drawn_improvement_win_rate']),
      playRate: _parseDouble(json['play_rate']),
      imageUrl: json['url'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class CardSearchState {
  final String expansion;
  final String format;
  final List<CardRating> allCards;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final String sortBy;
  final bool sortAscending;

  const CardSearchState({
    this.expansion = 'FDN',
    this.format = 'PremierDraft',
    this.allCards = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.sortBy = 'gihWr',
    this.sortAscending = false,
  });

  List<CardRating> get filteredCards {
    var cards = allCards.where((c) {
      if (searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    cards.sort((a, b) {
      int cmp;
      switch (sortBy) {
        case 'gihWr':
          cmp = (a.gihWinRate ?? -1).compareTo(b.gihWinRate ?? -1);
          break;
        case 'ata':
          cmp = (a.avgPick ?? 99).compareTo(b.avgPick ?? 99);
          break;
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        default:
          cmp = 0;
      }
      return sortAscending ? cmp : -cmp;
    });

    return cards;
  }

  CardSearchState copyWith({
    String? expansion,
    String? format,
    List<CardRating>? allCards,
    String? searchQuery,
    bool? isLoading,
    String? error,
    String? sortBy,
    bool? sortAscending,
  }) {
    return CardSearchState(
      expansion: expansion ?? this.expansion,
      format: format ?? this.format,
      allCards: allCards ?? this.allCards,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class CardSearchNotifier extends StateNotifier<CardSearchState> {
  CardSearchNotifier() : super(const CardSearchState());

  void setExpansion(String expansion) {
    state = state.copyWith(expansion: expansion.toUpperCase());
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(String sortBy) {
    if (state.sortBy == sortBy) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(
        sortBy: sortBy,
        sortAscending: sortBy == 'name' || sortBy == 'ata',
      );
    }
  }

  Future<void> fetchCards() async {
    if (state.expansion.isEmpty) {
      state = state.copyWith(error: 'Enter a set code');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final url = Uri.parse(
        'https://www.17lands.com/card_ratings/data'
        '?expansion=${state.expansion}'
        '&format=${state.format}',
      );

      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cards = data
            .map((e) => CardRating.fromJson(e as Map<String, dynamic>))
            .toList();

        if (cards.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            allCards: [],
            error: 'No data found for ${state.expansion} ${state.format}',
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            allCards: cards,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load data (${response.statusCode})',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString().split(':').first}',
      );
    }
  }
}

final cardSearchProvider =
    StateNotifierProvider<CardSearchNotifier, CardSearchState>(
  (ref) => CardSearchNotifier(),
);

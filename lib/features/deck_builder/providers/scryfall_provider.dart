import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ScryfallAutocompleteState {
  final List<String> suggestions;
  final bool isLoading;

  const ScryfallAutocompleteState({
    this.suggestions = const [],
    this.isLoading = false,
  });
}

class ScryfallAutocompleteNotifier
    extends StateNotifier<ScryfallAutocompleteState> {
  ScryfallAutocompleteNotifier()
      : super(const ScryfallAutocompleteState());

  Timer? _debounce;

  void search(String query) {
    _debounce?.cancel();

    if (query.length < 2) {
      state = const ScryfallAutocompleteState();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    state = ScryfallAutocompleteState(
      suggestions: state.suggestions,
      isLoading: true,
    );

    try {
      final url = Uri.parse(
        'https://api.scryfall.com/cards/autocomplete?q=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final names = (data['data'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
        state = ScryfallAutocompleteState(suggestions: names);
      } else {
        state = const ScryfallAutocompleteState();
      }
    } catch (_) {
      state = const ScryfallAutocompleteState();
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const ScryfallAutocompleteState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final scryfallAutocompleteProvider = StateNotifierProvider<
    ScryfallAutocompleteNotifier, ScryfallAutocompleteState>(
  (ref) => ScryfallAutocompleteNotifier(),
);

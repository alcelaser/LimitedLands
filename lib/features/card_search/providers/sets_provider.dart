import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class MtgSet {
  final String code;
  final String name;
  final String setType;
  final String? releasedAt;

  const MtgSet({
    required this.code,
    required this.name,
    required this.setType,
    this.releasedAt,
  });

  factory MtgSet.fromJson(Map<String, dynamic> json) {
    return MtgSet(
      code: (json['code'] as String).toUpperCase(),
      name: json['name'] as String? ?? '',
      setType: json['set_type'] as String? ?? '',
      releasedAt: json['released_at'] as String?,
    );
  }
}

class SetsState {
  final List<MtgSet> sets;
  final bool isLoading;
  final bool hasFetched;

  const SetsState({
    this.sets = const [],
    this.isLoading = false,
    this.hasFetched = false,
  });
}

const _draftableTypes = {
  'core',
  'expansion',
  'masters',
  'draft_innovation',
  'funny',
};

class SetsNotifier extends StateNotifier<SetsState> {
  SetsNotifier() : super(const SetsState());

  Future<void> fetchSets() async {
    if (state.hasFetched || state.isLoading) return;

    state = SetsState(
      sets: state.sets,
      isLoading: true,
      hasFetched: false,
    );

    try {
      final url = Uri.parse('https://api.scryfall.com/sets');
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawSets = (data['data'] as List<dynamic>)
            .map((e) => MtgSet.fromJson(e as Map<String, dynamic>))
            .where((s) => _draftableTypes.contains(s.setType))
            .toList();

        // Sort by release date descending (newest first)
        rawSets.sort((a, b) {
          final aDate = a.releasedAt ?? '';
          final bDate = b.releasedAt ?? '';
          return bDate.compareTo(aDate);
        });

        state = SetsState(sets: rawSets, hasFetched: true);
      } else {
        state = const SetsState(hasFetched: true);
      }
    } catch (_) {
      state = const SetsState(hasFetched: true);
    }
  }

  List<MtgSet> search(String query) {
    if (query.isEmpty) return state.sets.take(10).toList();

    final upper = query.toUpperCase();
    final lower = query.toLowerCase();

    return state.sets.where((s) {
      return s.code.startsWith(upper) ||
          s.name.toLowerCase().contains(lower);
    }).take(10).toList();
  }
}

final setsProvider = StateNotifierProvider<SetsNotifier, SetsState>(
  (ref) => SetsNotifier(),
);

import 'dart:convert';
import 'package:http/http.dart' as http;

class ScryfallImageService {
  ScryfallImageService._();

  /// Builds a Scryfall image URL from an exact card name.
  static String imageUrlFromName(String cardName) {
    return 'https://api.scryfall.com/cards/named'
        '?exact=${Uri.encodeComponent(cardName)}'
        '&format=image&version=normal';
  }

  /// Builds a Scryfall image URL from a set code and collector number.
  static String imageUrlFromSetAndNumber(
      String setCode, String collectorNumber) {
    return 'https://api.scryfall.com/cards'
        '/${Uri.encodeComponent(setCode.toLowerCase())}'
        '/${Uri.encodeComponent(collectorNumber)}'
        '?format=image&version=normal';
  }

  /// Matches "FDN 123", "FDN/123", "fdn 123", "FDN/123a".
  static final RegExp setNumberPattern = RegExp(
    r'^([A-Za-z0-9]{3,5})\s*[\/\s]\s*(\d+[a-z]?)$',
  );

  /// Returns true if input looks like a set+number pattern.
  static bool isSetNumberInput(String input) {
    return setNumberPattern.hasMatch(input.trim());
  }

  /// Parses set+number input into (setCode, collectorNumber) or null.
  static (String setCode, String collectorNumber)? parseSetNumber(
      String input) {
    final match = setNumberPattern.firstMatch(input.trim());
    if (match == null) return null;
    return (match.group(1)!.toLowerCase(), match.group(2)!);
  }

  /// Resolves a set code + collector number to a card name via Scryfall API.
  static Future<String?> resolveCardName(
      String setCode, String collectorNumber) async {
    try {
      final url = Uri.parse(
        'https://api.scryfall.com/cards'
        '/${Uri.encodeComponent(setCode.toLowerCase())}'
        '/${Uri.encodeComponent(collectorNumber)}',
      );
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['name'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches EUR prices for a list of card names using Scryfall collection API.
  /// Returns a map of card name (lowercase) -> EUR price.
  /// Batches requests in groups of 75 (Scryfall limit).
  static Future<Map<String, double?>> fetchPrices(
      List<String> cardNames) async {
    final prices = <String, double?>{};
    if (cardNames.isEmpty) return prices;

    // Deduplicate
    final unique = cardNames.toSet().toList();

    // Batch in groups of 75
    for (int i = 0; i < unique.length; i += 75) {
      final batch = unique.sublist(
          i, i + 75 > unique.length ? unique.length : i + 75);
      final identifiers =
          batch.map((name) => {'name': name}).toList();

      try {
        final url =
            Uri.parse('https://api.scryfall.com/cards/collection');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'identifiers': identifiers}),
        );
        if (response.statusCode == 200) {
          final body =
              jsonDecode(response.body) as Map<String, dynamic>;
          final data = body['data'] as List<dynamic>? ?? [];
          for (final card in data) {
            final cardMap = card as Map<String, dynamic>;
            final name = cardMap['name'] as String?;
            final pricesMap =
                cardMap['prices'] as Map<String, dynamic>?;
            if (name != null && pricesMap != null) {
              final eur = pricesMap['eur'] as String?;
              prices[name.toLowerCase()] =
                  eur != null ? double.tryParse(eur) : null;
            }
          }
        }
      } catch (_) {
        // Skip failed batch
      }

      // Respect Scryfall rate limit (100ms between requests)
      if (i + 75 < unique.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    return prices;
  }
}

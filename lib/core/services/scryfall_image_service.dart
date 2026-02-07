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
}

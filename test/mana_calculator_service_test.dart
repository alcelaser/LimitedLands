import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/mana_calculator/domain/models/mana_input.dart';
import 'package:limited_lands/features/mana_calculator/domain/services/mana_calculator_service.dart';

void main() {
  late ProportionalManaCalculator calculator;

  setUp(() {
    calculator = ProportionalManaCalculator();
  });

  group('ProportionalManaCalculator', () {
    test('returns empty recommendation for empty input', () {
      const input = ManaInput();
      final result = calculator.calculate(input);

      expect(result.landCounts, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.totalLands, 0);
    });

    test('returns empty recommendation for all-zero symbols', () {
      const input = ManaInput(symbolCounts: {'W': 0, 'U': 0});
      final result = calculator.calculate(input);

      expect(result.landCounts, isEmpty);
    });

    test('assigns all lands to single color', () {
      const input = ManaInput(
        symbolCounts: {'W': 10},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      expect(result.landCounts.length, 1);
      expect(result.landCounts[0].manaType, 'W');
      expect(result.landCounts[0].count, 17);
      expect(result.landCounts[0].isSplash, false);
    });

    test('distributes proportionally for two colors', () {
      const input = ManaInput(
        symbolCounts: {'W': 12, 'U': 8},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      expect(result.landCounts.length, 2);

      final totalAssigned =
          result.landCounts.fold<int>(0, (sum, lc) => sum + lc.count);
      expect(totalAssigned, 17);

      // W should get more lands than U (12/20 vs 8/20)
      final white = result.landCounts.firstWhere((lc) => lc.manaType == 'W');
      final blue = result.landCounts.firstWhere((lc) => lc.manaType == 'U');
      expect(white.count, greaterThan(blue.count));
    });

    test('detects splash colors', () {
      const input = ManaInput(
        symbolCounts: {'W': 12, 'U': 8, 'B': 3},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      final black = result.landCounts.firstWhere((lc) => lc.manaType == 'B');
      // B is 3/23 = 13%, below 15% threshold
      expect(black.isSplash, true);
      expect(result.warnings, isNotEmpty);
    });

    test('ensures every color gets at least 1 land', () {
      const input = ManaInput(
        symbolCounts: {'W': 20, 'U': 20, 'B': 1},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      final black = result.landCounts.firstWhere((lc) => lc.manaType == 'B');
      expect(black.count, greaterThanOrEqualTo(1));
    });

    test('handles equal distribution across 5 colors', () {
      const input = ManaInput(
        symbolCounts: {'W': 4, 'U': 4, 'B': 4, 'R': 4, 'G': 4},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      expect(result.landCounts.length, 5);
      final totalAssigned =
          result.landCounts.fold<int>(0, (sum, lc) => sum + lc.count);
      expect(totalAssigned, 17);

      // Each should get 3 or 4 (17/5 = 3.4)
      for (final lc in result.landCounts) {
        expect(lc.count, inInclusiveRange(3, 4));
      }
    });

    test('total lands always sum correctly', () {
      const input = ManaInput(
        symbolCounts: {'W': 7, 'U': 5, 'R': 3},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      final totalAssigned =
          result.landCounts.fold<int>(0, (sum, lc) => sum + lc.count);
      expect(totalAssigned, 17);
    });

    test('works with constructed deck size', () {
      const input = ManaInput(
        symbolCounts: {'W': 20, 'U': 15},
        deckSize: 60,
        totalLands: 24,
      );
      final result = calculator.calculate(input);

      final totalAssigned =
          result.landCounts.fold<int>(0, (sum, lc) => sum + lc.count);
      expect(totalAssigned, 24);
    });

    test('percentages sum to approximately 1', () {
      const input = ManaInput(
        symbolCounts: {'W': 8, 'U': 6, 'B': 4},
        totalLands: 17,
      );
      final result = calculator.calculate(input);

      final totalPercentage =
          result.landCounts.fold<double>(0, (sum, lc) => sum + lc.percentage);
      expect(totalPercentage, closeTo(1.0, 0.01));
    });
  });
}

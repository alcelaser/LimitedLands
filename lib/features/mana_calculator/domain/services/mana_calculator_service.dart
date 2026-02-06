import '../models/mana_input.dart';
import '../../../../core/constants/mtg_constants.dart';

abstract class ManaCalculatorService {
  LandRecommendation calculate(ManaInput input);
}

class ProportionalManaCalculator implements ManaCalculatorService {
  @override
  LandRecommendation calculate(ManaInput input) {
    final symbolCounts = input.symbolCounts;
    final totalLands = input.totalLands;

    // Filter out zero-count colors
    final activeColors = Map<String, int>.fromEntries(
      symbolCounts.entries.where((e) => e.value > 0),
    );

    if (activeColors.isEmpty) {
      return const LandRecommendation();
    }

    final totalSymbols = activeColors.values.fold<int>(0, (a, b) => a + b);
    if (totalSymbols == 0) {
      return const LandRecommendation();
    }

    // Step 1: Calculate raw proportional lands
    final rawLands = <String, double>{};
    for (final entry in activeColors.entries) {
      rawLands[entry.key] = (entry.value / totalSymbols) * totalLands;
    }

    // Step 2: Floor all values
    final flooredLands = <String, int>{};
    for (final entry in rawLands.entries) {
      flooredLands[entry.key] = entry.value.floor();
    }

    // Step 3: Ensure every color with >=1 symbol gets at least 1 land
    for (final color in activeColors.keys) {
      if (flooredLands[color]! < 1) {
        flooredLands[color] = 1;
      }
    }

    // Step 4: Calculate deficit
    int currentTotal = flooredLands.values.fold<int>(0, (a, b) => a + b);
    int deficit = totalLands - currentTotal;

    // If deficit is negative (too many lands assigned due to minimum 1 rule),
    // reduce from colors with the most lands
    if (deficit < 0) {
      final sortedByCount = activeColors.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedByCount) {
        if (deficit >= 0) break;
        if (flooredLands[entry.key]! > 1) {
          flooredLands[entry.key] = flooredLands[entry.key]! - 1;
          deficit++;
        }
      }
    }

    // Step 5: Distribute remaining deficit (largest remainder method)
    if (deficit > 0) {
      final remainders = <String, double>{};
      for (final entry in rawLands.entries) {
        remainders[entry.key] = entry.value - flooredLands[entry.key]!;
      }

      final sortedByRemainder = remainders.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      int distributed = 0;
      for (final entry in sortedByRemainder) {
        if (distributed >= deficit) break;
        flooredLands[entry.key] = flooredLands[entry.key]! + 1;
        distributed++;
      }
    }

    // Step 6: Build results with splash detection
    final warnings = <String>[];
    final landCounts = <LandCount>[];
    final finalTotal = flooredLands.values.fold<int>(0, (a, b) => a + b);

    for (final manaType in MtgConstants.manaTypes) {
      final count = flooredLands[manaType];
      if (count == null || count == 0) continue;

      final symbolRatio = activeColors[manaType]! / totalSymbols;
      final isSplash = symbolRatio < MtgConstants.splashThreshold;

      if (isSplash) {
        final colorName = MtgConstants.manaNames[manaType] ?? manaType;
        warnings.add(
          '$colorName is a splash color (${(symbolRatio * 100).toStringAsFixed(0)}% of symbols). '
          'Consider if $count ${MtgConstants.basicLandNames[manaType]} is worth the inconsistency.',
        );
      }

      landCounts.add(LandCount(
        manaType: manaType,
        count: count,
        percentage: finalTotal > 0 ? count / finalTotal : 0,
        isSplash: isSplash,
      ));
    }

    return LandRecommendation(
      landCounts: landCounts,
      warnings: warnings,
      totalLands: finalTotal,
    );
  }
}

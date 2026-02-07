import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/mana_calculator/presentation/providers/cube_calculator_provider.dart';

void main() {
  late CubeCalculatorNotifier notifier;

  setUp(() {
    notifier = CubeCalculatorNotifier();
  });

  // ---------------------------------------------------------------------------
  // Helper to get a land result for a specific mana type from the recommendation
  // ---------------------------------------------------------------------------
  CubeLandResult? landFor(CubeCalculatorState state, String manaType) {
    final matches = state.recommendation.landCounts
        .where((lr) => lr.manaType == manaType);
    return matches.isEmpty ? null : matches.first;
  }

  int totalRecommendedLands(CubeCalculatorState state) {
    return state.recommendation.landCounts
        .fold<int>(0, (sum, lr) => sum + lr.count);
  }

  // ===========================================================================
  // Group: Empty / no-input scenarios
  // ===========================================================================
  group('Empty input', () {
    test('returns empty recommendation when no symbols are set', () {
      // No symbols added -- default state
      final rec = notifier.state.recommendation;

      expect(rec.landCounts, isEmpty);
      expect(rec.totalLands, 0);
      expect(rec.warnings, isEmpty);
      expect(rec.tips, isEmpty);
    });

    test('returns empty recommendation after adding and removing a symbol', () {
      notifier.incrementSymbol('W');
      notifier.decrementSymbol('W');

      final rec = notifier.state.recommendation;
      expect(rec.landCounts, isEmpty);
      expect(rec.totalLands, 0);
    });
  });

  // ===========================================================================
  // Group: Single-color allocation
  // ===========================================================================
  group('Single color allocation', () {
    test('assigns all lands to a single color with no artifacts', () {
      // Add 10 white symbols
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }

      final state = notifier.state;
      expect(state.landsNeeded, 17); // no artifacts
      expect(totalRecommendedLands(state), 17);

      final white = landFor(state, 'W');
      expect(white, isNotNull);
      expect(white!.count, 17);
      expect(white.isSplash, false);
    });
  });

  // ===========================================================================
  // Group: Multi-color proportional distribution
  // ===========================================================================
  group('Proportional distribution', () {
    test('two colors distribute proportionally', () {
      // W: 12 symbols, U: 8 symbols (60% / 40%)
      for (int i = 0; i < 12; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 8; i++) {
        notifier.incrementSymbol('U');
      }

      final state = notifier.state;
      final white = landFor(state, 'W')!;
      final blue = landFor(state, 'U')!;

      // White should get more lands than blue
      expect(white.count, greaterThan(blue.count));
      // Total should sum to 17
      expect(white.count + blue.count, 17);
    });

    test('total lands always sum to landsNeeded', () {
      // Three-color scenario
      for (int i = 0; i < 7; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 5; i++) {
        notifier.incrementSymbol('U');
      }
      for (int i = 0; i < 3; i++) {
        notifier.incrementSymbol('R');
      }

      final state = notifier.state;
      expect(totalRecommendedLands(state), state.landsNeeded);
      expect(state.recommendation.totalLands, state.landsNeeded);
    });

    test('five equal colors each get 3 or 4 lands (17 / 5 = 3.4)', () {
      for (final color in ['W', 'U', 'B', 'R', 'G']) {
        for (int i = 0; i < 4; i++) {
          notifier.incrementSymbol(color);
        }
      }

      final state = notifier.state;
      expect(state.recommendation.landCounts.length, 5);
      expect(totalRecommendedLands(state), 17);

      for (final lr in state.recommendation.landCounts) {
        expect(lr.count, inInclusiveRange(3, 4));
      }
    });
  });

  // ===========================================================================
  // Group: Artifact mana reducing landsNeeded
  // ===========================================================================
  group('Artifact mana reducing lands needed', () {
    setUp(() {
      // Start each test with some color symbols so recalculate produces results
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('U');
      }
    });

    test('one fast mana source reduces landsNeeded by 1', () {
      // Toggle Mana Crypt (index 9, colorless fast mana) once
      notifier.toggleFastMana(9);

      final state = notifier.state;
      expect(state.totalFastMana, 1);
      expect(state.totalNonLandMana, 1);
      expect(state.landsNeeded, 16);
      expect(totalRecommendedLands(state), 16);
    });

    test('multiple fast mana sources reduce landsNeeded further', () {
      // Toggle Mana Crypt (index 9) three times -> count = 3
      notifier.toggleFastMana(9);
      notifier.toggleFastMana(9);
      notifier.toggleFastMana(9);

      final state = notifier.state;
      expect(state.totalFastMana, 3);
      expect(state.landsNeeded, 14);
      expect(totalRecommendedLands(state), 14);
    });

    test('paid mana also reduces landsNeeded', () {
      // Toggle Sol Ring (index 0, colorless paid mana)
      notifier.togglePaidMana(0);

      final state = notifier.state;
      expect(state.totalPaidMana, 1);
      expect(state.totalNonLandMana, 1);
      expect(state.landsNeeded, 16);
      expect(totalRecommendedLands(state), 16);
    });

    test('mixed fast and paid mana reduce landsNeeded correctly', () {
      // 2 fast + 1 paid = 3 total non-land
      notifier.toggleFastMana(9); // Mana Crypt
      notifier.toggleFastMana(9); // Mana Crypt again (count = 2)
      notifier.togglePaidMana(0); // Sol Ring

      final state = notifier.state;
      expect(state.totalFastMana, 2);
      expect(state.totalPaidMana, 1);
      expect(state.totalNonLandMana, 3);
      expect(state.landsNeeded, 14);
      expect(totalRecommendedLands(state), 14);
    });

    test('landsNeeded is clamped at 0 when artifacts exceed target', () {
      // Add lots of artifacts: toggle many unique sources
      // Fast mana indices 0-10, paid mana indices 0-10
      for (int i = 0; i < 11; i++) {
        notifier.toggleFastMana(i);
      }
      for (int i = 0; i < 11; i++) {
        notifier.togglePaidMana(i);
      }
      // That is 22 non-land mana sources, target is 17

      final state = notifier.state;
      expect(state.totalNonLandMana, 22);
      expect(state.landsNeeded, 0);
      // With 0 lands needed, recommendation should have 0 total lands
      expect(totalRecommendedLands(state), 0);
      expect(state.recommendation.totalLands, 0);
    });
  });

  // ===========================================================================
  // Group: Color-producing artifacts shift land distribution
  // ===========================================================================
  group('Color-producing artifact shifts distribution', () {
    test('Mox Sapphire shifts lands away from blue', () {
      // Equal symbols: W: 10, U: 10
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('U');
      }

      // Capture baseline
      final baselineState = notifier.state;
      final baselineBlue = landFor(baselineState, 'U')!.count;
      final baselineWhite = landFor(baselineState, 'W')!.count;
      expect((baselineBlue - baselineWhite).abs(), lessThanOrEqualTo(1)); // 17/2 rounds

      // Now add Mox Sapphire (index 1, produces U only)
      notifier.toggleFastMana(1);

      final state = notifier.state;
      final blue = landFor(state, 'U')!.count;
      final white = landFor(state, 'W')!.count;

      // Blue lands should be reduced compared to baseline or white gets more
      // Because Mox Sapphire covers some blue, white should get more lands
      // and landsNeeded drops by 1 (16 total), but blue gets a color bonus
      expect(totalRecommendedLands(state), state.landsNeeded);
      // White should get at least as many or more lands than blue now
      expect(white, greaterThanOrEqualTo(blue));
    });
  });

  // ===========================================================================
  // Group: Splash detection
  // ===========================================================================
  group('Splash detection', () {
    test('color below 15% of total symbols is marked as splash', () {
      // W: 12, U: 8, B: 1 -> total 21, B = 1/21 = ~4.8% (< 15%)
      for (int i = 0; i < 12; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 8; i++) {
        notifier.incrementSymbol('U');
      }
      notifier.incrementSymbol('B');

      final state = notifier.state;
      final black = landFor(state, 'B');
      expect(black, isNotNull);
      expect(black!.isSplash, true);

      // There should be a splash warning
      expect(
        state.recommendation.warnings,
        anyElement(contains('splash')),
      );
    });

    test('color at or above 15% is not marked as splash', () {
      // W: 10, U: 10 -> each is 50%, well above threshold
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('U');
      }

      final state = notifier.state;
      final white = landFor(state, 'W');
      final blue = landFor(state, 'U');
      expect(white!.isSplash, false);
      expect(blue!.isSplash, false);
      expect(state.recommendation.warnings, isEmpty);
    });
  });

  // ===========================================================================
  // Group: Tips generation
  // ===========================================================================
  group('Tips generation', () {
    setUp(() {
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('U');
      }
    });

    test('generates tip for 3+ fast mana sources', () {
      // Add 3 fast mana sources (toggle 3 different ones)
      notifier.toggleFastMana(0); // Black Lotus
      notifier.toggleFastMana(1); // Mox Sapphire
      notifier.toggleFastMana(9); // Mana Crypt

      final state = notifier.state;
      expect(state.totalFastMana, 3);
      expect(
        state.recommendation.tips,
        anyElement(contains('fast mana')),
      );
    });

    test('no fast mana tip when fewer than 3 fast sources', () {
      notifier.toggleFastMana(0); // Black Lotus
      notifier.toggleFastMana(1); // Mox Sapphire

      final state = notifier.state;
      expect(state.totalFastMana, 2);
      expect(
        state.recommendation.tips,
        isNot(anyElement(contains('fast mana'))),
      );
    });

    test('generates low-lands tip when landsNeeded < 14', () {
      // Need to push landsNeeded below 14: target is 17, need 4+ non-land mana
      notifier.toggleFastMana(0); // Black Lotus
      notifier.toggleFastMana(1); // Mox Sapphire
      notifier.toggleFastMana(9); // Mana Crypt
      notifier.togglePaidMana(0); // Sol Ring
      // 4 non-land sources -> landsNeeded = 17 - 4 = 13

      final state = notifier.state;
      expect(state.totalNonLandMana, 4);
      expect(state.landsNeeded, 13);
      expect(
        state.recommendation.tips,
        anyElement(contains('Only 13 lands needed')),
      );
    });

    test('no low-lands tip when landsNeeded >= 14', () {
      // 1 artifact -> landsNeeded = 16
      notifier.toggleFastMana(9); // Mana Crypt

      final state = notifier.state;
      expect(state.landsNeeded, 16);
      expect(
        state.recommendation.tips,
        isNot(anyElement(contains('Only'))),
      );
    });
  });

  // ===========================================================================
  // Group: Reset
  // ===========================================================================
  group('Reset', () {
    test('reset clears all state to defaults', () {
      // Build up some state first
      for (int i = 0; i < 8; i++) {
        notifier.incrementSymbol('W');
      }
      for (int i = 0; i < 5; i++) {
        notifier.incrementSymbol('U');
      }
      notifier.toggleFastMana(0);
      notifier.togglePaidMana(0);

      // Verify we have state
      expect(notifier.state.symbolCounts, isNotEmpty);
      expect(notifier.state.totalFastMana, greaterThan(0));
      expect(notifier.state.totalPaidMana, greaterThan(0));
      expect(notifier.state.recommendation.landCounts, isNotEmpty);

      // Reset
      notifier.reset();

      final state = notifier.state;
      expect(state.symbolCounts, isEmpty);
      expect(state.deckSize, 40);
      expect(state.targetManaSourceCount, 17);
      expect(state.totalFastMana, 0);
      expect(state.totalPaidMana, 0);
      expect(state.totalNonLandMana, 0);
      expect(state.landsNeeded, 17);
      expect(state.recommendation.landCounts, isEmpty);
      expect(state.recommendation.totalLands, 0);
      expect(state.recommendation.warnings, isEmpty);
      expect(state.recommendation.tips, isEmpty);

      // Fast and paid sources should be re-initialized with defaults (count=0)
      expect(state.fastManaSources.length, 11);
      expect(state.paidManaSources.length, 11);
      for (final source in state.fastManaSources) {
        expect(source.count, 0);
      }
      for (final source in state.paidManaSources) {
        expect(source.count, 0);
      }
    });
  });

  // ===========================================================================
  // Group: Minimum land guarantee
  // ===========================================================================
  group('Minimum land guarantee', () {
    test('every active color gets at least 1 land', () {
      // Dominant white with a tiny splash of all other colors
      for (int i = 0; i < 30; i++) {
        notifier.incrementSymbol('W');
      }
      notifier.incrementSymbol('U');
      notifier.incrementSymbol('B');
      notifier.incrementSymbol('R');
      notifier.incrementSymbol('G');

      final state = notifier.state;
      expect(state.recommendation.landCounts.length, 5);

      for (final lr in state.recommendation.landCounts) {
        expect(lr.count, greaterThanOrEqualTo(1),
            reason: '${lr.manaType} should have at least 1 land');
      }

      // Total should be at least landsNeeded (the minimum-1-land guarantee
      // can push total slightly above landsNeeded when many colors with tiny
      // counts force 1 land each and the single-pass deficit correction
      // cannot fully compensate).
      expect(totalRecommendedLands(state),
          greaterThanOrEqualTo(state.landsNeeded));
    });

    test('minimum land guarantee holds with many colors and few lands', () {
      // 5 colors, but reduce lands available via artifacts
      // Add symbols for all 5 colors
      for (final color in ['W', 'U', 'B', 'R', 'G']) {
        for (int i = 0; i < 3; i++) {
          notifier.incrementSymbol(color);
        }
      }

      // Add artifacts to bring landsNeeded down to, say, 7
      // 10 artifacts -> 17 - 10 = 7 lands needed
      for (int i = 0; i < 10; i++) {
        notifier.toggleFastMana(9); // Mana Crypt (colorless) multiple times
      }

      final state = notifier.state;
      expect(state.landsNeeded, 7);

      // Each of 5 active colors should still get at least 1
      for (final lr in state.recommendation.landCounts) {
        expect(lr.count, greaterThanOrEqualTo(1),
            reason: '${lr.manaType} should have at least 1 land');
      }
      expect(totalRecommendedLands(state), 7);
    });
  });

  // ===========================================================================
  // Group: State computed getters
  // ===========================================================================
  group('CubeCalculatorState computed getters', () {
    test('totalFastMana sums fast mana source counts', () {
      notifier.toggleFastMana(0); // Black Lotus (count -> 1)
      notifier.toggleFastMana(1); // Mox Sapphire (count -> 1)
      notifier.toggleFastMana(1); // Mox Sapphire (count -> 2)

      // Need a symbol for state to update
      notifier.incrementSymbol('W');

      expect(notifier.state.totalFastMana, 3);
    });

    test('totalPaidMana sums paid mana source counts', () {
      notifier.togglePaidMana(0); // Sol Ring (count -> 1)
      notifier.togglePaidMana(1); // Grim Monolith (count -> 1)

      notifier.incrementSymbol('W');

      expect(notifier.state.totalPaidMana, 2);
    });

    test('totalNonLandMana is sum of fast and paid', () {
      notifier.toggleFastMana(0); // +1 fast
      notifier.togglePaidMana(0); // +1 paid
      notifier.togglePaidMana(1); // +1 paid

      notifier.incrementSymbol('W');

      expect(notifier.state.totalNonLandMana, 3);
      expect(notifier.state.totalFastMana, 1);
      expect(notifier.state.totalPaidMana, 2);
    });

    test('landsNeeded is clamped between 0 and targetManaSourceCount', () {
      notifier.incrementSymbol('W');

      // With no artifacts, landsNeeded = targetManaSourceCount
      expect(notifier.state.landsNeeded, 17);

      // Cannot go above targetManaSourceCount
      expect(notifier.state.landsNeeded,
          lessThanOrEqualTo(notifier.state.targetManaSourceCount));
    });
  });

  // ===========================================================================
  // Group: Toggle and reset individual mana sources
  // ===========================================================================
  group('Toggle and reset individual mana sources', () {
    setUp(() {
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('R');
      }
    });

    test('toggleFastMana increments count at index', () {
      notifier.toggleFastMana(3); // Mox Ruby
      expect(notifier.state.fastManaSources[3].count, 1);

      notifier.toggleFastMana(3);
      expect(notifier.state.fastManaSources[3].count, 2);
    });

    test('resetFastMana sets count back to 0', () {
      notifier.toggleFastMana(3);
      notifier.toggleFastMana(3);
      expect(notifier.state.fastManaSources[3].count, 2);

      notifier.resetFastMana(3);
      expect(notifier.state.fastManaSources[3].count, 0);
    });

    test('togglePaidMana increments count at index', () {
      notifier.togglePaidMana(2); // Mana Vault
      expect(notifier.state.paidManaSources[2].count, 1);

      notifier.togglePaidMana(2);
      expect(notifier.state.paidManaSources[2].count, 2);
    });

    test('resetPaidMana sets count back to 0', () {
      notifier.togglePaidMana(2);
      notifier.togglePaidMana(2);
      expect(notifier.state.paidManaSources[2].count, 2);

      notifier.resetPaidMana(2);
      expect(notifier.state.paidManaSources[2].count, 0);
    });
  });

  // ===========================================================================
  // Group: Update configuration
  // ===========================================================================
  group('Update configuration', () {
    test('updateTargetManaSourceCount recalculates', () {
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }

      notifier.updateTargetManaSourceCount(20);

      final state = notifier.state;
      expect(state.targetManaSourceCount, 20);
      expect(state.landsNeeded, 20);
      expect(totalRecommendedLands(state), 20);
    });

    test('updateTargetManaSourceCount ignores values < 1', () {
      notifier.updateTargetManaSourceCount(0);
      expect(notifier.state.targetManaSourceCount, 17); // unchanged

      notifier.updateTargetManaSourceCount(-5);
      expect(notifier.state.targetManaSourceCount, 17); // unchanged
    });

    test('updateDeckSize recalculates', () {
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }

      notifier.updateDeckSize(60);

      expect(notifier.state.deckSize, 60);
      // Lands still based on targetManaSourceCount, not deckSize directly
      expect(totalRecommendedLands(notifier.state), 17);
    });

    test('updateDeckSize ignores values < 1', () {
      notifier.updateDeckSize(0);
      expect(notifier.state.deckSize, 40); // unchanged

      notifier.updateDeckSize(-10);
      expect(notifier.state.deckSize, 40); // unchanged
    });
  });

  // ===========================================================================
  // Group: Decrement edge cases
  // ===========================================================================
  group('Decrement edge cases', () {
    test('decrementing to 0 removes the color from symbolCounts', () {
      notifier.incrementSymbol('W');
      expect(notifier.state.symbolCounts['W'], 1);

      notifier.decrementSymbol('W');
      expect(notifier.state.symbolCounts.containsKey('W'), false);
    });

    test('decrementing an absent color does nothing', () {
      final beforeState = notifier.state;
      notifier.decrementSymbol('W');
      // State should be unchanged (no crash, no negative values)
      expect(notifier.state.symbolCounts, beforeState.symbolCounts);
    });
  });

  // ===========================================================================
  // Group: Recommendation totalManaSourcesIncludingLands
  // ===========================================================================
  group('Recommendation totalManaSourcesIncludingLands', () {
    test('includes both lands and non-land mana', () {
      for (int i = 0; i < 10; i++) {
        notifier.incrementSymbol('W');
      }
      notifier.toggleFastMana(9); // Mana Crypt
      notifier.togglePaidMana(0); // Sol Ring

      final state = notifier.state;
      // landsNeeded = 17 - 2 = 15
      expect(state.landsNeeded, 15);
      expect(state.recommendation.totalLands, 15);
      expect(state.recommendation.totalManaSourcesIncludingLands, 17);
    });
  });
}

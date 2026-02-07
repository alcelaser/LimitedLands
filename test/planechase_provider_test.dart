import 'package:flutter_test/flutter_test.dart';
import 'package:limited_lands/features/life_counter/models/planechase_model.dart';
import 'package:limited_lands/features/life_counter/providers/planechase_provider.dart';

void main() {
  group('PlanechaseNotifier', () {
    late PlanechaseNotifier notifier;

    setUp(() {
      notifier = PlanechaseNotifier();
    });

    test('initial state is not initialized', () {
      expect(notifier.state.isInitialized, false);
      expect(notifier.state.deck, isEmpty);
      expect(notifier.state.currentPlane, isNull);
    });

    test('initializeDeck sets up deck and current plane', () {
      notifier.initializeDeck();
      expect(notifier.state.isInitialized, true);
      expect(notifier.state.currentPlane, isNotNull);
      expect(notifier.state.deck.length, greaterThan(0));
      // Current plane + deck should equal all planes
      expect(notifier.state.deck.length + 1, 86);
      expect(notifier.state.discard, isEmpty);
    });

    test('planeswalk moves current to discard and draws new', () {
      notifier.initializeDeck();
      final first = notifier.state.currentPlane!;
      notifier.planeswalk();
      expect(notifier.state.currentPlane, isNotNull);
      expect(notifier.state.currentPlane!.id, isNot(first.id));
      expect(notifier.state.discard.length, 1);
      expect(notifier.state.discard.first.id, first.id);
    });

    test('planeswalk reshuffles when deck is empty', () {
      notifier.initializeDeck();
      // Walk through entire deck
      final totalPlanes = notifier.state.deck.length + 1;
      for (int i = 0; i < totalPlanes; i++) {
        notifier.planeswalk();
      }
      // Should have reshuffled and still have a current plane
      expect(notifier.state.currentPlane, isNotNull);
    });

    test('rollPlanarDie returns valid result', () {
      notifier.initializeDeck();
      final result = notifier.rollPlanarDie();
      expect(
        result,
        isIn([
          PlanarDieResult.planeswalk,
          PlanarDieResult.chaos,
          PlanarDieResult.blank,
        ]),
      );
      expect(notifier.state.lastDieRoll, isNotNull);
    });

    test('rollPlanarDie auto-planeswalks on planeswalk result', () {
      notifier.initializeDeck();
      // Roll many times to trigger a planeswalk
      bool gotPlaneswalk = false;
      for (int i = 0; i < 100; i++) {
        final firstPlane = notifier.state.currentPlane;
        final result = notifier.rollPlanarDie();
        if (result == PlanarDieResult.planeswalk) {
          gotPlaneswalk = true;
          // Should have moved to a new plane (current differs from firstPlane)
          expect(notifier.state.currentPlane?.id, isNot(firstPlane?.id));
          expect(notifier.state.discard, isNotEmpty);
          break;
        } else {
          // If not planeswalk, current plane may be the same (unless previous was planeswalk)
          // Just ensure state is valid
          expect(notifier.state.currentPlane, isNotNull);
        }
      }
      // We should eventually get a planeswalk in 100 tries (1/6 chance each)
      // This is a probabilistic test but extremely unlikely to fail
      expect(gotPlaneswalk, true);
    });

    test('reshuffleDeck combines deck and discard', () {
      notifier.initializeDeck();
      // Walk a few times to build up discard
      notifier.planeswalk();
      notifier.planeswalk();
      notifier.planeswalk();
      final current = notifier.state.currentPlane;
      final totalCards = notifier.state.deck.length + notifier.state.discard.length;

      notifier.reshuffleDeck();

      expect(notifier.state.deck.length, totalCards);
      expect(notifier.state.discard, isEmpty);
      expect(notifier.state.currentPlane?.id, current?.id);
    });

    test('reset clears all state', () {
      notifier.initializeDeck();
      notifier.planeswalk();
      notifier.reset();
      expect(notifier.state.isInitialized, false);
      expect(notifier.state.deck, isEmpty);
      expect(notifier.state.currentPlane, isNull);
    });

    test('planeswalk does nothing when not initialized', () {
      notifier.planeswalk();
      expect(notifier.state.currentPlane, isNull);
    });
  });
}

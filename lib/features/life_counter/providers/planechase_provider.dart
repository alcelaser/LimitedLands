import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planechase_model.dart';

/// Hardcoded planar cards from official Planechase sets.
const _allPlanes = <PlanarCard>[
  PlanarCard(id: 'p01', name: 'Academy at Tolaria West', typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p02', name: 'Agyrem', typeLine: 'Plane — Ravnica', setCode: 'HOP'),
  PlanarCard(id: 'p03', name: 'Akoum', typeLine: 'Plane — Zendikar', setCode: 'PC2'),
  PlanarCard(id: 'p04', name: 'Astral Arena', typeLine: 'Plane — Kolbahan', setCode: 'PC2'),
  PlanarCard(id: 'p05', name: 'Bant', typeLine: 'Plane — Alara', setCode: 'HOP'),
  PlanarCard(id: 'p06', name: 'Bloodhill Bastion', typeLine: 'Plane — Equilor', setCode: 'PC2'),
  PlanarCard(id: 'p07', name: 'Celestine Reef', typeLine: 'Plane — Luvion', setCode: 'PC2'),
  PlanarCard(id: 'p08', name: 'Cliffside Market', typeLine: 'Plane — Mercadia', setCode: 'HOP'),
  PlanarCard(id: 'p09', name: 'Edge of Malacol', typeLine: 'Plane — Belenon', setCode: 'PC2'),
  PlanarCard(id: 'p10', name: 'Eloren Wilds', typeLine: 'Plane — Shandalar', setCode: 'HOP'),
  PlanarCard(id: 'p11', name: 'Feeding Grounds', typeLine: 'Plane — Muraganda', setCode: 'HOP'),
  PlanarCard(id: 'p12', name: 'Fields of Summer', typeLine: 'Plane — Moag', setCode: 'HOP'),
  PlanarCard(id: 'p13', name: 'Furnace Layer', typeLine: 'Plane — New Phyrexia', setCode: 'PC2'),
  PlanarCard(id: 'p14', name: 'Gavony', typeLine: 'Plane — Innistrad', setCode: 'PC2'),
  PlanarCard(id: 'p15', name: 'Glen Elendra', typeLine: 'Plane — Lorwyn', setCode: 'HOP'),
  PlanarCard(id: 'p16', name: 'Glimmervoid Basin', typeLine: 'Plane — Mirrodin', setCode: 'HOP'),
  PlanarCard(id: 'p17', name: 'Goldmeadow', typeLine: 'Plane — Lorwyn', setCode: 'HOP'),
  PlanarCard(id: 'p18', name: 'Grand Ossuary', typeLine: 'Plane — Ravnica', setCode: 'PC2'),
  PlanarCard(id: 'p19', name: 'Grixis', typeLine: 'Plane — Alara', setCode: 'HOP'),
  PlanarCard(id: 'p20', name: 'Grove of the Dreampods', typeLine: 'Plane — Fabacin', setCode: 'PC2'),
  PlanarCard(id: 'p21', name: 'Hedron Fields of Agadeem', typeLine: 'Plane — Zendikar', setCode: 'PC2'),
  PlanarCard(id: 'p22', name: 'Immersturm', typeLine: 'Plane — Valla', setCode: 'HOP'),
  PlanarCard(id: 'p23', name: 'Isle of Vesuva', typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p24', name: "Izzet Steam Maze", typeLine: 'Plane — Ravnica', setCode: 'HOP'),
  PlanarCard(id: 'p25', name: 'Jund', typeLine: 'Plane — Alara', setCode: 'PC2'),
  PlanarCard(id: 'p26', name: 'Kessig', typeLine: 'Plane — Innistrad', setCode: 'PC2'),
  PlanarCard(id: 'p27', name: 'Kharasha Foothills', typeLine: 'Plane — Mongseng', setCode: 'PC2'),
  PlanarCard(id: 'p28', name: 'Kilnspire District', typeLine: 'Plane — Ravnica', setCode: 'PC2'),
  PlanarCard(id: 'p29', name: "Krosa", typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p30', name: "Lair of the Ashen Idol", typeLine: 'Plane — Azgol', setCode: 'PC2'),
  PlanarCard(id: 'p31', name: 'Lethe Lake', typeLine: 'Plane — Arkhos', setCode: 'HOP'),
  PlanarCard(id: 'p32', name: 'Llanowar', typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p33', name: 'Minamo', typeLine: 'Plane — Kamigawa', setCode: 'PC2'),
  PlanarCard(id: 'p34', name: "Murasa", typeLine: 'Plane — Zendikar', setCode: 'PC2'),
  PlanarCard(id: 'p35', name: 'Naar Isle', typeLine: 'Plane — Wildfire', setCode: 'HOP'),
  PlanarCard(id: 'p36', name: 'Naya', typeLine: 'Plane — Alara', setCode: 'HOP'),
  PlanarCard(id: 'p37', name: 'Nephalia', typeLine: 'Plane — Innistrad', setCode: 'PC2'),
  PlanarCard(id: 'p38', name: 'Norn\'s Dominion', typeLine: 'Plane — New Phyrexia', setCode: 'PC2'),
  PlanarCard(id: 'p39', name: 'Onakke Catacomb', typeLine: 'Plane — Shandalar', setCode: 'PC2'),
  PlanarCard(id: 'p40', name: 'Orochi Colony', typeLine: 'Plane — Kamigawa', setCode: 'PC2'),
  PlanarCard(id: 'p41', name: 'Otaria', typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p42', name: 'Panopticon', typeLine: 'Plane — Mirrodin', setCode: 'HOP'),
  PlanarCard(id: 'p43', name: 'Pools of Becoming', typeLine: 'Plane — Bolas\'s Meditation Realm', setCode: 'HOP'),
  PlanarCard(id: 'p44', name: 'Prahv', typeLine: 'Plane — Ravnica', setCode: 'PC2'),
  PlanarCard(id: 'p45', name: 'Quicksilver Sea', typeLine: 'Plane — Mirrodin', setCode: 'PC2'),
  PlanarCard(id: 'p46', name: 'Raven\'s Run', typeLine: 'Plane — Shadowmoor', setCode: 'HOP'),
  PlanarCard(id: 'p47', name: 'Sanctum of Serra', typeLine: 'Plane — Serra\'s Realm', setCode: 'HOP'),
  PlanarCard(id: 'p48', name: 'Sea of Sand', typeLine: 'Plane — Rabiah', setCode: 'HOP'),
  PlanarCard(id: 'p49', name: 'Selesnya Loft Gardens', typeLine: 'Plane — Ravnica', setCode: 'PC2'),
  PlanarCard(id: 'p50', name: 'Shiv', typeLine: 'Plane — Dominaria', setCode: 'HOP'),
  PlanarCard(id: 'p51', name: 'Skybreen', typeLine: 'Plane — Kaldheim', setCode: 'HOP'),
  PlanarCard(id: 'p52', name: 'Sokenzan', typeLine: 'Plane — Kamigawa', setCode: 'HOP'),
  PlanarCard(id: 'p53', name: 'Stairs to Infinity', typeLine: 'Plane — Xerex', setCode: 'PC2'),
  PlanarCard(id: 'p54', name: 'Stensia', typeLine: 'Plane — Innistrad', setCode: 'PC2'),
  PlanarCard(id: 'p55', name: 'Stronghold Furnace', typeLine: 'Plane — Rath', setCode: 'PC2'),
  PlanarCard(id: 'p56', name: 'Takenuma', typeLine: 'Plane — Kamigawa', setCode: 'PC2'),
  PlanarCard(id: 'p57', name: 'Tazeem', typeLine: 'Plane — Zendikar', setCode: 'PC2'),
  PlanarCard(id: 'p58', name: 'The Aether Flues', typeLine: 'Plane — Iquatana', setCode: 'HOP'),
  PlanarCard(id: 'p59', name: 'The Dark Barony', typeLine: 'Plane — Ulgrotha', setCode: 'HOP'),
  PlanarCard(id: 'p60', name: 'The Eon Fog', typeLine: 'Plane — Ergamon', setCode: 'PC2'),
  PlanarCard(id: 'p61', name: 'The Fourth Sphere', typeLine: 'Plane — Phyrexia', setCode: 'HOP'),
  PlanarCard(id: 'p62', name: 'The Great Forest', typeLine: 'Plane — Lorwyn', setCode: 'HOP'),
  PlanarCard(id: 'p63', name: 'The Hippodrome', typeLine: 'Plane — Segovia', setCode: 'PC2'),
  PlanarCard(id: 'p64', name: 'The Maelstrom', typeLine: 'Plane — Alara', setCode: 'HOP'),
  PlanarCard(id: 'p65', name: 'The Zephyr Maze', typeLine: 'Plane — Iquatana', setCode: 'PC2'),
  PlanarCard(id: 'p66', name: 'Trail of the Mage-Rings', typeLine: 'Plane — Vryn', setCode: 'PC2'),
  PlanarCard(id: 'p67', name: 'Truga Jungle', typeLine: 'Plane — Ergamon', setCode: 'PC2'),
  PlanarCard(id: 'p68', name: 'Turri Island', typeLine: 'Plane — Ir', setCode: 'HOP'),
  PlanarCard(id: 'p69', name: 'Undercity Reaches', typeLine: 'Plane — Ravnica', setCode: 'HOP'),
  PlanarCard(id: 'p70', name: 'Velis Vel', typeLine: 'Plane — Lorwyn', setCode: 'HOP'),
  PlanarCard(id: 'p71', name: 'Windriddle Palaces', typeLine: 'Plane — Belenon', setCode: 'PC2'),
  PlanarCard(id: 'p72', name: 'Mirrored Depths', typeLine: 'Plane — Karsus', setCode: 'PC2'),
  PlanarCard(id: 'p73', name: 'Mount Keralia', typeLine: 'Plane — Regatha', setCode: 'PC2'),
  PlanarCard(id: 'p74', name: 'Orzhova', typeLine: 'Plane — Ravnica', setCode: 'PC2'),
  PlanarCard(id: 'p75', name: 'Stensia', typeLine: 'Plane — Innistrad', setCode: 'PC2'),
  PlanarCard(id: 'p76', name: 'Talon Gates', typeLine: 'Plane — Dominaria', setCode: 'PC2'),
  PlanarCard(id: 'p77', name: 'The Fertile Lands', typeLine: 'Plane — Ergamon', setCode: 'PC2'),
  PlanarCard(id: 'p78', name: 'Tember City', typeLine: 'Plane — Kinshala', setCode: 'PC2'),
  PlanarCard(id: 'p79', name: 'Towashi', typeLine: 'Plane — Kamigawa', setCode: 'PC2'),
  PlanarCard(id: 'p80', name: 'The Pit', typeLine: 'Plane — Phyrexia', setCode: 'PC2'),
  PlanarCard(id: 'p81', name: 'Norns Seedcore', typeLine: 'Plane — New Phyrexia', setCode: 'PC2'),
  PlanarCard(id: 'p82', name: 'Aretopolis', typeLine: 'Plane — Kephalai', setCode: 'PC2'),
  PlanarCard(id: 'p83', name: 'The Great Aerie', typeLine: 'Plane — Tarkir', setCode: 'PC2'),
  PlanarCard(id: 'p84', name: 'Chaotic Aether', typeLine: 'Phenomenon', setCode: 'PC2'),
  PlanarCard(id: 'p85', name: 'Interplanar Tunnel', typeLine: 'Phenomenon', setCode: 'PC2'),
  PlanarCard(id: 'p86', name: 'Spatial Merging', typeLine: 'Phenomenon', setCode: 'PC2'),
];

class PlanechaseNotifier extends StateNotifier<PlanechaseState> {
  PlanechaseNotifier() : super(const PlanechaseState());

  final _random = Random();

  void initializeDeck() {
    final shuffled = List<PlanarCard>.from(_allPlanes)..shuffle(_random);
    final first = shuffled.removeAt(0);
    state = PlanechaseState(
      deck: shuffled,
      discard: [],
      currentPlane: first,
      isInitialized: true,
    );
  }

  void planeswalk() {
    if (!state.isInitialized) return;

    var deck = List<PlanarCard>.from(state.deck);
    var discard = List<PlanarCard>.from(state.discard);

    // Move current plane to discard
    if (state.currentPlane != null) {
      discard.add(state.currentPlane!);
    }

    // If deck is empty, reshuffle discard
    if (deck.isEmpty) {
      deck = List<PlanarCard>.from(discard)..shuffle(_random);
      discard = [];
    }

    if (deck.isEmpty) return;

    final next = deck.removeAt(0);
    state = PlanechaseState(
      deck: deck,
      discard: discard,
      currentPlane: next,
      isInitialized: true,
    );
  }

  PlanarDieResult rollPlanarDie() {
    final roll = _random.nextInt(6);
    PlanarDieResult result;
    if (roll == 0) {
      result = PlanarDieResult.planeswalk;
    } else if (roll == 1) {
      result = PlanarDieResult.chaos;
    } else {
      result = PlanarDieResult.blank;
    }

    state = state.copyWith(lastDieRoll: result);

    if (result == PlanarDieResult.planeswalk) {
      planeswalk();
    }

    return result;
  }

  void reshuffleDeck() {
    if (!state.isInitialized) return;

    final allCards = <PlanarCard>[
      ...state.deck,
      ...state.discard,
    ]..shuffle(_random);

    state = PlanechaseState(
      deck: allCards,
      discard: [],
      currentPlane: state.currentPlane,
      isInitialized: true,
    );
  }

  void reset() {
    state = const PlanechaseState();
  }
}

final planechaseProvider =
    StateNotifierProvider<PlanechaseNotifier, PlanechaseState>(
  (ref) => PlanechaseNotifier(),
);

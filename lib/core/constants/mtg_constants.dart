class MtgConstants {
  MtgConstants._();

  // Deck sizes
  static const int defaultLimitedDeckSize = 40;
  static const int defaultConstructedDeckSize = 60;

  // Land counts
  static const int defaultLimitedLandCount = 17;
  static const int defaultConstructedLandCount = 24;

  // Thresholds
  static const double splashThreshold = 0.15;

  // Mana types
  static const List<String> manaTypes = ['W', 'U', 'B', 'R', 'G'];

  // Mana type names
  static const Map<String, String> manaNames = {
    'W': 'White',
    'U': 'Blue',
    'B': 'Black',
    'R': 'Red',
    'G': 'Green',
  };

  // Basic land names
  static const Map<String, String> basicLandNames = {
    'W': 'Plains',
    'U': 'Island',
    'B': 'Swamp',
    'R': 'Mountain',
    'G': 'Forest',
  };

  // Format presets
  static const Map<String, Map<String, int>> formatPresets = {
    'Limited (40)': {
      'deckSize': 40,
      'landCount': 17,
    },
    'Constructed (60)': {
      'deckSize': 60,
      'landCount': 24,
    },
  };

  // ── Life Counter ──────────────────────────────────────────────────

  // Starting life totals
  static const int standardStartingLife = 20;
  static const int commanderStartingLife = 40;

  // Lethal thresholds
  static const int poisonLethalThreshold = 10;
  static const int commanderDamageLethal = 21;

  // Limits
  static const int maxPlayers = 10;
  static const int minPlayers = 2;
  static const int maxLifeHistory = 100;
  static const int maxCounterValue = 999;
  static const int maxPoisonValue = 99;
  static const int maxCommanderTax = 99;

  // Mana pool types (includes colorless)
  static const List<String> manaPoolTypes = ['W', 'U', 'B', 'R', 'G', 'C'];

  // Player color palette (ARGB hex values for serialization)
  static const List<int> playerColors = [
    0xFFE53935, // Red
    0xFF1E88E5, // Blue
    0xFF43A047, // Green
    0xFFFDD835, // Yellow
    0xFF8E24AA, // Purple
    0xFFFF8F00, // Orange
    0xFF00ACC1, // Cyan
    0xFFD81B60, // Pink
    0xFF5E35B1, // Deep Purple
    0xFF00897B, // Teal
  ];
}

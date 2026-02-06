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
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'mana_input.freezed.dart';
part 'mana_input.g.dart';

@freezed
class ManaInput with _$ManaInput {
  const factory ManaInput({
    @Default({}) Map<String, int> symbolCounts,
    @Default(40) int deckSize,
    @Default(17) int totalLands,
  }) = _ManaInput;

  factory ManaInput.fromJson(Map<String, dynamic> json) =>
      _$ManaInputFromJson(json);
}

@freezed
class LandCount with _$LandCount {
  const factory LandCount({
    required String manaType,
    required int count,
    required double percentage,
    required bool isSplash,
  }) = _LandCount;

  factory LandCount.fromJson(Map<String, dynamic> json) =>
      _$LandCountFromJson(json);
}

@freezed
class LandRecommendation with _$LandRecommendation {
  const factory LandRecommendation({
    @Default([]) List<LandCount> landCounts,
    @Default([]) List<String> warnings,
    @Default(0) int totalLands,
  }) = _LandRecommendation;

  factory LandRecommendation.fromJson(Map<String, dynamic> json) =>
      _$LandRecommendationFromJson(json);
}

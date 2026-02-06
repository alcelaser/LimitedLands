// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mana_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ManaInputImpl _$$ManaInputImplFromJson(Map<String, dynamic> json) =>
    _$ManaInputImpl(
      symbolCounts: (json['symbolCounts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      deckSize: (json['deckSize'] as num?)?.toInt() ?? 40,
      totalLands: (json['totalLands'] as num?)?.toInt() ?? 17,
    );

Map<String, dynamic> _$$ManaInputImplToJson(_$ManaInputImpl instance) =>
    <String, dynamic>{
      'symbolCounts': instance.symbolCounts,
      'deckSize': instance.deckSize,
      'totalLands': instance.totalLands,
    };

_$LandCountImpl _$$LandCountImplFromJson(Map<String, dynamic> json) =>
    _$LandCountImpl(
      manaType: json['manaType'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      isSplash: json['isSplash'] as bool,
    );

Map<String, dynamic> _$$LandCountImplToJson(_$LandCountImpl instance) =>
    <String, dynamic>{
      'manaType': instance.manaType,
      'count': instance.count,
      'percentage': instance.percentage,
      'isSplash': instance.isSplash,
    };

_$LandRecommendationImpl _$$LandRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$LandRecommendationImpl(
      landCounts: (json['landCounts'] as List<dynamic>?)
              ?.map((e) => LandCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalLands: (json['totalLands'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LandRecommendationImplToJson(
        _$LandRecommendationImpl instance) =>
    <String, dynamic>{
      'landCounts': instance.landCounts,
      'warnings': instance.warnings,
      'totalLands': instance.totalLands,
    };

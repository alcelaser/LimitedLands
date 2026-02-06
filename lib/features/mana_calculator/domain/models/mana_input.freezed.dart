// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mana_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ManaInput _$ManaInputFromJson(Map<String, dynamic> json) {
  return _ManaInput.fromJson(json);
}

/// @nodoc
mixin _$ManaInput {
  Map<String, int> get symbolCounts => throw _privateConstructorUsedError;
  int get deckSize => throw _privateConstructorUsedError;
  int get totalLands => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ManaInputCopyWith<ManaInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManaInputCopyWith<$Res> {
  factory $ManaInputCopyWith(ManaInput value, $Res Function(ManaInput) then) =
      _$ManaInputCopyWithImpl<$Res, ManaInput>;
  @useResult
  $Res call({Map<String, int> symbolCounts, int deckSize, int totalLands});
}

/// @nodoc
class _$ManaInputCopyWithImpl<$Res, $Val extends ManaInput>
    implements $ManaInputCopyWith<$Res> {
  _$ManaInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbolCounts = null,
    Object? deckSize = null,
    Object? totalLands = null,
  }) {
    return _then(_value.copyWith(
      symbolCounts: null == symbolCounts
          ? _value.symbolCounts
          : symbolCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      deckSize: null == deckSize
          ? _value.deckSize
          : deckSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalLands: null == totalLands
          ? _value.totalLands
          : totalLands // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ManaInputImplCopyWith<$Res>
    implements $ManaInputCopyWith<$Res> {
  factory _$$ManaInputImplCopyWith(
          _$ManaInputImpl value, $Res Function(_$ManaInputImpl) then) =
      __$$ManaInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, int> symbolCounts, int deckSize, int totalLands});
}

/// @nodoc
class __$$ManaInputImplCopyWithImpl<$Res>
    extends _$ManaInputCopyWithImpl<$Res, _$ManaInputImpl>
    implements _$$ManaInputImplCopyWith<$Res> {
  __$$ManaInputImplCopyWithImpl(
      _$ManaInputImpl _value, $Res Function(_$ManaInputImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbolCounts = null,
    Object? deckSize = null,
    Object? totalLands = null,
  }) {
    return _then(_$ManaInputImpl(
      symbolCounts: null == symbolCounts
          ? _value._symbolCounts
          : symbolCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      deckSize: null == deckSize
          ? _value.deckSize
          : deckSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalLands: null == totalLands
          ? _value.totalLands
          : totalLands // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ManaInputImpl implements _ManaInput {
  const _$ManaInputImpl(
      {final Map<String, int> symbolCounts = const {},
      this.deckSize = 40,
      this.totalLands = 17})
      : _symbolCounts = symbolCounts;

  factory _$ManaInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$ManaInputImplFromJson(json);

  final Map<String, int> _symbolCounts;
  @override
  @JsonKey()
  Map<String, int> get symbolCounts {
    if (_symbolCounts is EqualUnmodifiableMapView) return _symbolCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_symbolCounts);
  }

  @override
  @JsonKey()
  final int deckSize;
  @override
  @JsonKey()
  final int totalLands;

  @override
  String toString() {
    return 'ManaInput(symbolCounts: $symbolCounts, deckSize: $deckSize, totalLands: $totalLands)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManaInputImpl &&
            const DeepCollectionEquality()
                .equals(other._symbolCounts, _symbolCounts) &&
            (identical(other.deckSize, deckSize) ||
                other.deckSize == deckSize) &&
            (identical(other.totalLands, totalLands) ||
                other.totalLands == totalLands));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_symbolCounts), deckSize, totalLands);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ManaInputImplCopyWith<_$ManaInputImpl> get copyWith =>
      __$$ManaInputImplCopyWithImpl<_$ManaInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ManaInputImplToJson(
      this,
    );
  }
}

abstract class _ManaInput implements ManaInput {
  const factory _ManaInput(
      {final Map<String, int> symbolCounts,
      final int deckSize,
      final int totalLands}) = _$ManaInputImpl;

  factory _ManaInput.fromJson(Map<String, dynamic> json) =
      _$ManaInputImpl.fromJson;

  @override
  Map<String, int> get symbolCounts;
  @override
  int get deckSize;
  @override
  int get totalLands;
  @override
  @JsonKey(ignore: true)
  _$$ManaInputImplCopyWith<_$ManaInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LandCount _$LandCountFromJson(Map<String, dynamic> json) {
  return _LandCount.fromJson(json);
}

/// @nodoc
mixin _$LandCount {
  String get manaType => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;
  bool get isSplash => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LandCountCopyWith<LandCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LandCountCopyWith<$Res> {
  factory $LandCountCopyWith(LandCount value, $Res Function(LandCount) then) =
      _$LandCountCopyWithImpl<$Res, LandCount>;
  @useResult
  $Res call({String manaType, int count, double percentage, bool isSplash});
}

/// @nodoc
class _$LandCountCopyWithImpl<$Res, $Val extends LandCount>
    implements $LandCountCopyWith<$Res> {
  _$LandCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manaType = null,
    Object? count = null,
    Object? percentage = null,
    Object? isSplash = null,
  }) {
    return _then(_value.copyWith(
      manaType: null == manaType
          ? _value.manaType
          : manaType // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      isSplash: null == isSplash
          ? _value.isSplash
          : isSplash // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LandCountImplCopyWith<$Res>
    implements $LandCountCopyWith<$Res> {
  factory _$$LandCountImplCopyWith(
          _$LandCountImpl value, $Res Function(_$LandCountImpl) then) =
      __$$LandCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String manaType, int count, double percentage, bool isSplash});
}

/// @nodoc
class __$$LandCountImplCopyWithImpl<$Res>
    extends _$LandCountCopyWithImpl<$Res, _$LandCountImpl>
    implements _$$LandCountImplCopyWith<$Res> {
  __$$LandCountImplCopyWithImpl(
      _$LandCountImpl _value, $Res Function(_$LandCountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? manaType = null,
    Object? count = null,
    Object? percentage = null,
    Object? isSplash = null,
  }) {
    return _then(_$LandCountImpl(
      manaType: null == manaType
          ? _value.manaType
          : manaType // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as double,
      isSplash: null == isSplash
          ? _value.isSplash
          : isSplash // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LandCountImpl implements _LandCount {
  const _$LandCountImpl(
      {required this.manaType,
      required this.count,
      required this.percentage,
      required this.isSplash});

  factory _$LandCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$LandCountImplFromJson(json);

  @override
  final String manaType;
  @override
  final int count;
  @override
  final double percentage;
  @override
  final bool isSplash;

  @override
  String toString() {
    return 'LandCount(manaType: $manaType, count: $count, percentage: $percentage, isSplash: $isSplash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LandCountImpl &&
            (identical(other.manaType, manaType) ||
                other.manaType == manaType) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.isSplash, isSplash) ||
                other.isSplash == isSplash));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, manaType, count, percentage, isSplash);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LandCountImplCopyWith<_$LandCountImpl> get copyWith =>
      __$$LandCountImplCopyWithImpl<_$LandCountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LandCountImplToJson(
      this,
    );
  }
}

abstract class _LandCount implements LandCount {
  const factory _LandCount(
      {required final String manaType,
      required final int count,
      required final double percentage,
      required final bool isSplash}) = _$LandCountImpl;

  factory _LandCount.fromJson(Map<String, dynamic> json) =
      _$LandCountImpl.fromJson;

  @override
  String get manaType;
  @override
  int get count;
  @override
  double get percentage;
  @override
  bool get isSplash;
  @override
  @JsonKey(ignore: true)
  _$$LandCountImplCopyWith<_$LandCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LandRecommendation _$LandRecommendationFromJson(Map<String, dynamic> json) {
  return _LandRecommendation.fromJson(json);
}

/// @nodoc
mixin _$LandRecommendation {
  List<LandCount> get landCounts => throw _privateConstructorUsedError;
  List<String> get warnings => throw _privateConstructorUsedError;
  int get totalLands => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LandRecommendationCopyWith<LandRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LandRecommendationCopyWith<$Res> {
  factory $LandRecommendationCopyWith(
          LandRecommendation value, $Res Function(LandRecommendation) then) =
      _$LandRecommendationCopyWithImpl<$Res, LandRecommendation>;
  @useResult
  $Res call(
      {List<LandCount> landCounts, List<String> warnings, int totalLands});
}

/// @nodoc
class _$LandRecommendationCopyWithImpl<$Res, $Val extends LandRecommendation>
    implements $LandRecommendationCopyWith<$Res> {
  _$LandRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landCounts = null,
    Object? warnings = null,
    Object? totalLands = null,
  }) {
    return _then(_value.copyWith(
      landCounts: null == landCounts
          ? _value.landCounts
          : landCounts // ignore: cast_nullable_to_non_nullable
              as List<LandCount>,
      warnings: null == warnings
          ? _value.warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalLands: null == totalLands
          ? _value.totalLands
          : totalLands // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LandRecommendationImplCopyWith<$Res>
    implements $LandRecommendationCopyWith<$Res> {
  factory _$$LandRecommendationImplCopyWith(_$LandRecommendationImpl value,
          $Res Function(_$LandRecommendationImpl) then) =
      __$$LandRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LandCount> landCounts, List<String> warnings, int totalLands});
}

/// @nodoc
class __$$LandRecommendationImplCopyWithImpl<$Res>
    extends _$LandRecommendationCopyWithImpl<$Res, _$LandRecommendationImpl>
    implements _$$LandRecommendationImplCopyWith<$Res> {
  __$$LandRecommendationImplCopyWithImpl(_$LandRecommendationImpl _value,
      $Res Function(_$LandRecommendationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? landCounts = null,
    Object? warnings = null,
    Object? totalLands = null,
  }) {
    return _then(_$LandRecommendationImpl(
      landCounts: null == landCounts
          ? _value._landCounts
          : landCounts // ignore: cast_nullable_to_non_nullable
              as List<LandCount>,
      warnings: null == warnings
          ? _value._warnings
          : warnings // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalLands: null == totalLands
          ? _value.totalLands
          : totalLands // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LandRecommendationImpl implements _LandRecommendation {
  const _$LandRecommendationImpl(
      {final List<LandCount> landCounts = const [],
      final List<String> warnings = const [],
      this.totalLands = 0})
      : _landCounts = landCounts,
        _warnings = warnings;

  factory _$LandRecommendationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LandRecommendationImplFromJson(json);

  final List<LandCount> _landCounts;
  @override
  @JsonKey()
  List<LandCount> get landCounts {
    if (_landCounts is EqualUnmodifiableListView) return _landCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_landCounts);
  }

  final List<String> _warnings;
  @override
  @JsonKey()
  List<String> get warnings {
    if (_warnings is EqualUnmodifiableListView) return _warnings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warnings);
  }

  @override
  @JsonKey()
  final int totalLands;

  @override
  String toString() {
    return 'LandRecommendation(landCounts: $landCounts, warnings: $warnings, totalLands: $totalLands)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LandRecommendationImpl &&
            const DeepCollectionEquality()
                .equals(other._landCounts, _landCounts) &&
            const DeepCollectionEquality().equals(other._warnings, _warnings) &&
            (identical(other.totalLands, totalLands) ||
                other.totalLands == totalLands));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_landCounts),
      const DeepCollectionEquality().hash(_warnings),
      totalLands);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LandRecommendationImplCopyWith<_$LandRecommendationImpl> get copyWith =>
      __$$LandRecommendationImplCopyWithImpl<_$LandRecommendationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LandRecommendationImplToJson(
      this,
    );
  }
}

abstract class _LandRecommendation implements LandRecommendation {
  const factory _LandRecommendation(
      {final List<LandCount> landCounts,
      final List<String> warnings,
      final int totalLands}) = _$LandRecommendationImpl;

  factory _LandRecommendation.fromJson(Map<String, dynamic> json) =
      _$LandRecommendationImpl.fromJson;

  @override
  List<LandCount> get landCounts;
  @override
  List<String> get warnings;
  @override
  int get totalLands;
  @override
  @JsonKey(ignore: true)
  _$$LandRecommendationImplCopyWith<_$LandRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

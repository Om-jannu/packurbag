// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nearby_traveler.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NearbyTraveler {

 String get userId; String get username; double get distanceKm;
/// Create a copy of NearbyTraveler
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NearbyTravelerCopyWith<NearbyTraveler> get copyWith => _$NearbyTravelerCopyWithImpl<NearbyTraveler>(this as NearbyTraveler, _$identity);

  /// Serializes this NearbyTraveler to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NearbyTraveler&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,distanceKm);

@override
String toString() {
  return 'NearbyTraveler(userId: $userId, username: $username, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class $NearbyTravelerCopyWith<$Res>  {
  factory $NearbyTravelerCopyWith(NearbyTraveler value, $Res Function(NearbyTraveler) _then) = _$NearbyTravelerCopyWithImpl;
@useResult
$Res call({
 String userId, String username, double distanceKm
});




}
/// @nodoc
class _$NearbyTravelerCopyWithImpl<$Res>
    implements $NearbyTravelerCopyWith<$Res> {
  _$NearbyTravelerCopyWithImpl(this._self, this._then);

  final NearbyTraveler _self;
  final $Res Function(NearbyTraveler) _then;

/// Create a copy of NearbyTraveler
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? username = null,Object? distanceKm = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NearbyTraveler].
extension NearbyTravelerPatterns on NearbyTraveler {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NearbyTraveler value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NearbyTraveler() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NearbyTraveler value)  $default,){
final _that = this;
switch (_that) {
case _NearbyTraveler():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NearbyTraveler value)?  $default,){
final _that = this;
switch (_that) {
case _NearbyTraveler() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String username,  double distanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NearbyTraveler() when $default != null:
return $default(_that.userId,_that.username,_that.distanceKm);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String username,  double distanceKm)  $default,) {final _that = this;
switch (_that) {
case _NearbyTraveler():
return $default(_that.userId,_that.username,_that.distanceKm);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String username,  double distanceKm)?  $default,) {final _that = this;
switch (_that) {
case _NearbyTraveler() when $default != null:
return $default(_that.userId,_that.username,_that.distanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NearbyTraveler implements NearbyTraveler {
  const _NearbyTraveler({required this.userId, required this.username, required this.distanceKm});
  factory _NearbyTraveler.fromJson(Map<String, dynamic> json) => _$NearbyTravelerFromJson(json);

@override final  String userId;
@override final  String username;
@override final  double distanceKm;

/// Create a copy of NearbyTraveler
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NearbyTravelerCopyWith<_NearbyTraveler> get copyWith => __$NearbyTravelerCopyWithImpl<_NearbyTraveler>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NearbyTravelerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NearbyTraveler&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.username, username) || other.username == username)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,username,distanceKm);

@override
String toString() {
  return 'NearbyTraveler(userId: $userId, username: $username, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class _$NearbyTravelerCopyWith<$Res> implements $NearbyTravelerCopyWith<$Res> {
  factory _$NearbyTravelerCopyWith(_NearbyTraveler value, $Res Function(_NearbyTraveler) _then) = __$NearbyTravelerCopyWithImpl;
@override @useResult
$Res call({
 String userId, String username, double distanceKm
});




}
/// @nodoc
class __$NearbyTravelerCopyWithImpl<$Res>
    implements _$NearbyTravelerCopyWith<$Res> {
  __$NearbyTravelerCopyWithImpl(this._self, this._then);

  final _NearbyTraveler _self;
  final $Res Function(_NearbyTraveler) _then;

/// Create a copy of NearbyTraveler
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? username = null,Object? distanceKm = null,}) {
  return _then(_NearbyTraveler(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on

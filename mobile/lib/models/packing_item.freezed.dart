// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'packing_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackingItem {

@JsonKey(name: '_id') String get id; String get text; String get category; bool get packed;
/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackingItemCopyWith<PackingItem> get copyWith => _$PackingItemCopyWithImpl<PackingItem>(this as PackingItem, _$identity);

  /// Serializes this PackingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.category, category) || other.category == category)&&(identical(other.packed, packed) || other.packed == packed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,category,packed);

@override
String toString() {
  return 'PackingItem(id: $id, text: $text, category: $category, packed: $packed)';
}


}

/// @nodoc
abstract mixin class $PackingItemCopyWith<$Res>  {
  factory $PackingItemCopyWith(PackingItem value, $Res Function(PackingItem) _then) = _$PackingItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String text, String category, bool packed
});




}
/// @nodoc
class _$PackingItemCopyWithImpl<$Res>
    implements $PackingItemCopyWith<$Res> {
  _$PackingItemCopyWithImpl(this._self, this._then);

  final PackingItem _self;
  final $Res Function(PackingItem) _then;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? category = null,Object? packed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,packed: null == packed ? _self.packed : packed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PackingItem].
extension PackingItemPatterns on PackingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackingItem value)  $default,){
final _that = this;
switch (_that) {
case _PackingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackingItem value)?  $default,){
final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String text,  String category,  bool packed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
return $default(_that.id,_that.text,_that.category,_that.packed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String text,  String category,  bool packed)  $default,) {final _that = this;
switch (_that) {
case _PackingItem():
return $default(_that.id,_that.text,_that.category,_that.packed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String text,  String category,  bool packed)?  $default,) {final _that = this;
switch (_that) {
case _PackingItem() when $default != null:
return $default(_that.id,_that.text,_that.category,_that.packed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackingItem implements PackingItem {
  const _PackingItem({@JsonKey(name: '_id') required this.id, required this.text, this.category = 'General', this.packed = false});
  factory _PackingItem.fromJson(Map<String, dynamic> json) => _$PackingItemFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String text;
@override@JsonKey() final  String category;
@override@JsonKey() final  bool packed;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackingItemCopyWith<_PackingItem> get copyWith => __$PackingItemCopyWithImpl<_PackingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackingItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackingItem&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.category, category) || other.category == category)&&(identical(other.packed, packed) || other.packed == packed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,category,packed);

@override
String toString() {
  return 'PackingItem(id: $id, text: $text, category: $category, packed: $packed)';
}


}

/// @nodoc
abstract mixin class _$PackingItemCopyWith<$Res> implements $PackingItemCopyWith<$Res> {
  factory _$PackingItemCopyWith(_PackingItem value, $Res Function(_PackingItem) _then) = __$PackingItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String text, String category, bool packed
});




}
/// @nodoc
class __$PackingItemCopyWithImpl<$Res>
    implements _$PackingItemCopyWith<$Res> {
  __$PackingItemCopyWithImpl(this._self, this._then);

  final _PackingItem _self;
  final $Res Function(_PackingItem) _then;

/// Create a copy of PackingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? category = null,Object? packed = null,}) {
  return _then(_PackingItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,packed: null == packed ? _self.packed : packed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

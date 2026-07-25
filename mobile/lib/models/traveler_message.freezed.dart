// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traveler_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TravelerMessage {

@JsonKey(name: '_id') String get id; String get conversationId; String get senderId; String get receiverId; String get text; DateTime get createdAt;
/// Create a copy of TravelerMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TravelerMessageCopyWith<TravelerMessage> get copyWith => _$TravelerMessageCopyWithImpl<TravelerMessage>(this as TravelerMessage, _$identity);

  /// Serializes this TravelerMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TravelerMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,receiverId,text,createdAt);

@override
String toString() {
  return 'TravelerMessage(id: $id, conversationId: $conversationId, senderId: $senderId, receiverId: $receiverId, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TravelerMessageCopyWith<$Res>  {
  factory $TravelerMessageCopyWith(TravelerMessage value, $Res Function(TravelerMessage) _then) = _$TravelerMessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String conversationId, String senderId, String receiverId, String text, DateTime createdAt
});




}
/// @nodoc
class _$TravelerMessageCopyWithImpl<$Res>
    implements $TravelerMessageCopyWith<$Res> {
  _$TravelerMessageCopyWithImpl(this._self, this._then);

  final TravelerMessage _self;
  final $Res Function(TravelerMessage) _then;

/// Create a copy of TravelerMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? receiverId = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TravelerMessage].
extension TravelerMessagePatterns on TravelerMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TravelerMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TravelerMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TravelerMessage value)  $default,){
final _that = this;
switch (_that) {
case _TravelerMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TravelerMessage value)?  $default,){
final _that = this;
switch (_that) {
case _TravelerMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String conversationId,  String senderId,  String receiverId,  String text,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TravelerMessage() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.receiverId,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String conversationId,  String senderId,  String receiverId,  String text,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TravelerMessage():
return $default(_that.id,_that.conversationId,_that.senderId,_that.receiverId,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String conversationId,  String senderId,  String receiverId,  String text,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TravelerMessage() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.receiverId,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TravelerMessage implements TravelerMessage {
  const _TravelerMessage({@JsonKey(name: '_id') required this.id, required this.conversationId, required this.senderId, required this.receiverId, required this.text, required this.createdAt});
  factory _TravelerMessage.fromJson(Map<String, dynamic> json) => _$TravelerMessageFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String conversationId;
@override final  String senderId;
@override final  String receiverId;
@override final  String text;
@override final  DateTime createdAt;

/// Create a copy of TravelerMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TravelerMessageCopyWith<_TravelerMessage> get copyWith => __$TravelerMessageCopyWithImpl<_TravelerMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TravelerMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TravelerMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,receiverId,text,createdAt);

@override
String toString() {
  return 'TravelerMessage(id: $id, conversationId: $conversationId, senderId: $senderId, receiverId: $receiverId, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TravelerMessageCopyWith<$Res> implements $TravelerMessageCopyWith<$Res> {
  factory _$TravelerMessageCopyWith(_TravelerMessage value, $Res Function(_TravelerMessage) _then) = __$TravelerMessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String conversationId, String senderId, String receiverId, String text, DateTime createdAt
});




}
/// @nodoc
class __$TravelerMessageCopyWithImpl<$Res>
    implements _$TravelerMessageCopyWith<$Res> {
  __$TravelerMessageCopyWithImpl(this._self, this._then);

  final _TravelerMessage _self;
  final $Res Function(_TravelerMessage) _then;

/// Create a copy of TravelerMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? receiverId = null,Object? text = null,Object? createdAt = null,}) {
  return _then(_TravelerMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

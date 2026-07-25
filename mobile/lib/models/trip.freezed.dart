// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trip {

@JsonKey(name: '_id') String get id; String get title; String get destination; DateTime get startDate; DateTime get endDate; String get notes; String get coverColor; double? get budgetAmount; String get budgetCurrency; List<ItineraryItem> get itinerary; List<PackingItem> get packingItems; List<Expense> get expenses;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.coverColor, coverColor) || other.coverColor == coverColor)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.budgetCurrency, budgetCurrency) || other.budgetCurrency == budgetCurrency)&&const DeepCollectionEquality().equals(other.itinerary, itinerary)&&const DeepCollectionEquality().equals(other.packingItems, packingItems)&&const DeepCollectionEquality().equals(other.expenses, expenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,destination,startDate,endDate,notes,coverColor,budgetAmount,budgetCurrency,const DeepCollectionEquality().hash(itinerary),const DeepCollectionEquality().hash(packingItems),const DeepCollectionEquality().hash(expenses));

@override
String toString() {
  return 'Trip(id: $id, title: $title, destination: $destination, startDate: $startDate, endDate: $endDate, notes: $notes, coverColor: $coverColor, budgetAmount: $budgetAmount, budgetCurrency: $budgetCurrency, itinerary: $itinerary, packingItems: $packingItems, expenses: $expenses)';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id, String title, String destination, DateTime startDate, DateTime endDate, String notes, String coverColor, double? budgetAmount, String budgetCurrency, List<ItineraryItem> itinerary, List<PackingItem> packingItems, List<Expense> expenses
});




}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? destination = null,Object? startDate = null,Object? endDate = null,Object? notes = null,Object? coverColor = null,Object? budgetAmount = freezed,Object? budgetCurrency = null,Object? itinerary = null,Object? packingItems = null,Object? expenses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,coverColor: null == coverColor ? _self.coverColor : coverColor // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: freezed == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as double?,budgetCurrency: null == budgetCurrency ? _self.budgetCurrency : budgetCurrency // ignore: cast_nullable_to_non_nullable
as String,itinerary: null == itinerary ? _self.itinerary : itinerary // ignore: cast_nullable_to_non_nullable
as List<ItineraryItem>,packingItems: null == packingItems ? _self.packingItems : packingItems // ignore: cast_nullable_to_non_nullable
as List<PackingItem>,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<Expense>,
  ));
}

}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String title,  String destination,  DateTime startDate,  DateTime endDate,  String notes,  String coverColor,  double? budgetAmount,  String budgetCurrency,  List<ItineraryItem> itinerary,  List<PackingItem> packingItems,  List<Expense> expenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.coverColor,_that.budgetAmount,_that.budgetCurrency,_that.itinerary,_that.packingItems,_that.expenses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id,  String title,  String destination,  DateTime startDate,  DateTime endDate,  String notes,  String coverColor,  double? budgetAmount,  String budgetCurrency,  List<ItineraryItem> itinerary,  List<PackingItem> packingItems,  List<Expense> expenses)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.coverColor,_that.budgetAmount,_that.budgetCurrency,_that.itinerary,_that.packingItems,_that.expenses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id,  String title,  String destination,  DateTime startDate,  DateTime endDate,  String notes,  String coverColor,  double? budgetAmount,  String budgetCurrency,  List<ItineraryItem> itinerary,  List<PackingItem> packingItems,  List<Expense> expenses)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.title,_that.destination,_that.startDate,_that.endDate,_that.notes,_that.coverColor,_that.budgetAmount,_that.budgetCurrency,_that.itinerary,_that.packingItems,_that.expenses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trip implements Trip {
  const _Trip({@JsonKey(name: '_id') required this.id, required this.title, required this.destination, required this.startDate, required this.endDate, this.notes = '', this.coverColor = 'FF6B4A', this.budgetAmount, this.budgetCurrency = 'INR', final  List<ItineraryItem> itinerary = const [], final  List<PackingItem> packingItems = const [], final  List<Expense> expenses = const []}): _itinerary = itinerary,_packingItems = packingItems,_expenses = expenses;
  factory _Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override final  String title;
@override final  String destination;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override@JsonKey() final  String notes;
@override@JsonKey() final  String coverColor;
@override final  double? budgetAmount;
@override@JsonKey() final  String budgetCurrency;
 final  List<ItineraryItem> _itinerary;
@override@JsonKey() List<ItineraryItem> get itinerary {
  if (_itinerary is EqualUnmodifiableListView) return _itinerary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itinerary);
}

 final  List<PackingItem> _packingItems;
@override@JsonKey() List<PackingItem> get packingItems {
  if (_packingItems is EqualUnmodifiableListView) return _packingItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packingItems);
}

 final  List<Expense> _expenses;
@override@JsonKey() List<Expense> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}


/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.coverColor, coverColor) || other.coverColor == coverColor)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.budgetCurrency, budgetCurrency) || other.budgetCurrency == budgetCurrency)&&const DeepCollectionEquality().equals(other._itinerary, _itinerary)&&const DeepCollectionEquality().equals(other._packingItems, _packingItems)&&const DeepCollectionEquality().equals(other._expenses, _expenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,destination,startDate,endDate,notes,coverColor,budgetAmount,budgetCurrency,const DeepCollectionEquality().hash(_itinerary),const DeepCollectionEquality().hash(_packingItems),const DeepCollectionEquality().hash(_expenses));

@override
String toString() {
  return 'Trip(id: $id, title: $title, destination: $destination, startDate: $startDate, endDate: $endDate, notes: $notes, coverColor: $coverColor, budgetAmount: $budgetAmount, budgetCurrency: $budgetCurrency, itinerary: $itinerary, packingItems: $packingItems, expenses: $expenses)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id, String title, String destination, DateTime startDate, DateTime endDate, String notes, String coverColor, double? budgetAmount, String budgetCurrency, List<ItineraryItem> itinerary, List<PackingItem> packingItems, List<Expense> expenses
});




}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? destination = null,Object? startDate = null,Object? endDate = null,Object? notes = null,Object? coverColor = null,Object? budgetAmount = freezed,Object? budgetCurrency = null,Object? itinerary = null,Object? packingItems = null,Object? expenses = null,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,coverColor: null == coverColor ? _self.coverColor : coverColor // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: freezed == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as double?,budgetCurrency: null == budgetCurrency ? _self.budgetCurrency : budgetCurrency // ignore: cast_nullable_to_non_nullable
as String,itinerary: null == itinerary ? _self._itinerary : itinerary // ignore: cast_nullable_to_non_nullable
as List<ItineraryItem>,packingItems: null == packingItems ? _self._packingItems : packingItems // ignore: cast_nullable_to_non_nullable
as List<PackingItem>,expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<Expense>,
  ));
}


}

// dart format on

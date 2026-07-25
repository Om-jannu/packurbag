// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
  id: json['_id'] as String,
  title: json['title'] as String,
  destination: json['destination'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  notes: json['notes'] as String? ?? '',
  coverColor: json['coverColor'] as String? ?? 'FF6B4A',
  budgetAmount: (json['budgetAmount'] as num?)?.toDouble(),
  budgetCurrency: json['budgetCurrency'] as String? ?? 'INR',
  itinerary:
      (json['itinerary'] as List<dynamic>?)
          ?.map((e) => ItineraryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  packingItems:
      (json['packingItems'] as List<dynamic>?)
          ?.map((e) => PackingItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  expenses:
      (json['expenses'] as List<dynamic>?)
          ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'destination': instance.destination,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'notes': instance.notes,
  'coverColor': instance.coverColor,
  'budgetAmount': instance.budgetAmount,
  'budgetCurrency': instance.budgetCurrency,
  'itinerary': instance.itinerary,
  'packingItems': instance.packingItems,
  'expenses': instance.expenses,
};

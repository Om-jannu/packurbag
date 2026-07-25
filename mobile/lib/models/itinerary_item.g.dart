// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItineraryItem _$ItineraryItemFromJson(Map<String, dynamic> json) =>
    _ItineraryItem(
      id: json['_id'] as String,
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool? ?? false,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      dateOfCreation: json['dateOfCreation'] == null
          ? null
          : DateTime.parse(json['dateOfCreation'] as String),
    );

Map<String, dynamic> _$ItineraryItemToJson(_ItineraryItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'text': instance.text,
      'date': instance.date.toIso8601String(),
      'completed': instance.completed,
      'priority': instance.priority,
      'location': instance.location,
      'dateOfCreation': instance.dateOfCreation?.toIso8601String(),
    };

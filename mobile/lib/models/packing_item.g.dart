// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackingItem _$PackingItemFromJson(Map<String, dynamic> json) => _PackingItem(
  id: json['_id'] as String,
  text: json['text'] as String,
  category: json['category'] as String? ?? 'General',
  packed: json['packed'] as bool? ?? false,
);

Map<String, dynamic> _$PackingItemToJson(_PackingItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'text': instance.text,
      'category': instance.category,
      'packed': instance.packed,
    };

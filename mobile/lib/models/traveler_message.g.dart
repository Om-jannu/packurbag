// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traveler_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TravelerMessage _$TravelerMessageFromJson(Map<String, dynamic> json) =>
    _TravelerMessage(
      id: json['_id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TravelerMessageToJson(_TravelerMessage instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'text': instance.text,
      'createdAt': instance.createdAt.toIso8601String(),
    };

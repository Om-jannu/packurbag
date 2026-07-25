// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['_id'] as String,
  username: json['username'] as String,
  userEmail: json['userEmail'] as String,
  isDiscoverable: json['isDiscoverable'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  '_id': instance.id,
  'username': instance.username,
  'userEmail': instance.userEmail,
  'isDiscoverable': instance.isDiscoverable,
};

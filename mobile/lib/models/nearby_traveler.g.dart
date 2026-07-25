// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_traveler.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NearbyTraveler _$NearbyTravelerFromJson(Map<String, dynamic> json) =>
    _NearbyTraveler(
      userId: json['userId'] as String,
      username: json['username'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
    );

Map<String, dynamic> _$NearbyTravelerToJson(_NearbyTraveler instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'distanceKm': instance.distanceKm,
    };

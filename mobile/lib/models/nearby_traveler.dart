import 'package:freezed_annotation/freezed_annotation.dart';

part 'nearby_traveler.freezed.dart';
part 'nearby_traveler.g.dart';

@freezed
abstract class NearbyTraveler with _$NearbyTraveler {
  const factory NearbyTraveler({
    required String userId,
    required String username,
    required double distanceKm,
  }) = _NearbyTraveler;

  factory NearbyTraveler.fromJson(Map<String, dynamic> json) =>
      _$NearbyTravelerFromJson(json);
}

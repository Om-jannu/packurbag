import 'package:freezed_annotation/freezed_annotation.dart';

part 'itinerary_item.freezed.dart';
part 'itinerary_item.g.dart';

@freezed
abstract class ItineraryItem with _$ItineraryItem {
  const factory ItineraryItem({
    @JsonKey(name: '_id') required String id,
    required String text,
    required DateTime date,
    @Default(false) bool completed,
    @Default(0) int priority,
    @Default('') String location,
    DateTime? dateOfCreation,
  }) = _ItineraryItem;

  factory ItineraryItem.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemFromJson(json);
}

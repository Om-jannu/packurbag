import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense.dart';
import 'itinerary_item.dart';
import 'packing_item.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
abstract class Trip with _$Trip {
  const factory Trip({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    @Default('') String notes,
    @Default('FF6B4A') String coverColor,
    double? budgetAmount,
    @Default('INR') String budgetCurrency,
    @Default([]) List<ItineraryItem> itinerary,
    @Default([]) List<PackingItem> packingItems,
    @Default([]) List<Expense> expenses,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

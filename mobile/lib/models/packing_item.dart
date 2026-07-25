import 'package:freezed_annotation/freezed_annotation.dart';

part 'packing_item.freezed.dart';
part 'packing_item.g.dart';

@freezed
abstract class PackingItem with _$PackingItem {
  const factory PackingItem({
    @JsonKey(name: '_id') required String id,
    required String text,
    @Default('General') String category,
    @Default(false) bool packed,
  }) = _PackingItem;

  factory PackingItem.fromJson(Map<String, dynamic> json) =>
      _$PackingItemFromJson(json);
}

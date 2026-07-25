import 'package:freezed_annotation/freezed_annotation.dart';

part 'traveler_message.freezed.dart';
part 'traveler_message.g.dart';

@freezed
abstract class TravelerMessage with _$TravelerMessage {
  const factory TravelerMessage({
    @JsonKey(name: '_id') required String id,
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
    required DateTime createdAt,
  }) = _TravelerMessage;

  factory TravelerMessage.fromJson(Map<String, dynamic> json) =>
      _$TravelerMessageFromJson(json);
}

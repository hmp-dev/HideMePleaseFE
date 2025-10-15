import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_stats_entity.dart';

part 'friend_stats_dto.g.dart';

@JsonSerializable()
class FriendStatsDto extends Equatable {
  @JsonKey(name: "totalFriends")
  final int? totalFriends;

  @JsonKey(name: "receivedRequests")
  final int? receivedRequests;

  @JsonKey(name: "sentRequests")
  final int? sentRequests;

  const FriendStatsDto({
    this.totalFriends,
    this.receivedRequests,
    this.sentRequests,
  });

  factory FriendStatsDto.fromJson(Map<String, dynamic> json) =>
      _$FriendStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendStatsDtoToJson(this);

  FriendStatsEntity toEntity() {
    return FriendStatsEntity(
      totalFriends: totalFriends ?? 0,
      receivedRequests: receivedRequests ?? 0,
      sentRequests: sentRequests ?? 0,
    );
  }

  @override
  List<Object?> get props => [totalFriends, receivedRequests, sentRequests];
}

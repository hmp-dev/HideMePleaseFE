import 'package:equatable/equatable.dart';

class FriendStatsEntity extends Equatable {
  final int totalFriends;
  final int receivedRequests;
  final int sentRequests;

  const FriendStatsEntity({
    required this.totalFriends,
    required this.receivedRequests,
    required this.sentRequests,
  });

  const FriendStatsEntity.empty()
      : totalFriends = 0,
        receivedRequests = 0,
        sentRequests = 0;

  @override
  List<Object?> get props => [totalFriends, receivedRequests, sentRequests];
}

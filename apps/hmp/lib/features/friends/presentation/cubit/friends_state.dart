part of 'friends_cubit.dart';

class FriendsState extends Equatable {
  final RequestStatus submitStatus;
  final RequestStatus queryStatus; // 친구 관계 조회 전용 상태
  final String errorMessage;
  final FriendshipStatus? friendshipStatus;
  final String? friendshipId;
  final FriendStatsEntity? friendStats;
  final List<FriendshipEntity> friendsList;
  final List<FriendRequestEntity> receivedRequests;
  final List<FriendRequestEntity> sentRequests;
  final PaginationEntity? friendsPagination;
  final PaginationEntity? receivedPagination;
  final PaginationEntity? sentPagination;

  const FriendsState({
    required this.submitStatus,
    required this.queryStatus,
    required this.errorMessage,
    this.friendshipStatus,
    this.friendshipId,
    this.friendStats,
    this.friendsList = const [],
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.friendsPagination,
    this.receivedPagination,
    this.sentPagination,
  });

  factory FriendsState.initial() {
    return const FriendsState(
      submitStatus: RequestStatus.initial,
      queryStatus: RequestStatus.initial,
      errorMessage: '',
      friendshipStatus: null,
      friendshipId: null,
      friendStats: null,
      friendsList: [],
      receivedRequests: [],
      sentRequests: [],
      friendsPagination: null,
      receivedPagination: null,
      sentPagination: null,
    );
  }

  FriendsState copyWith({
    RequestStatus? submitStatus,
    RequestStatus? queryStatus,
    String? errorMessage,
    FriendshipStatus? friendshipStatus,
    bool clearFriendshipStatus = false,
    String? friendshipId,
    bool clearFriendshipId = false,
    FriendStatsEntity? friendStats,
    List<FriendshipEntity>? friendsList,
    List<FriendRequestEntity>? receivedRequests,
    List<FriendRequestEntity>? sentRequests,
    PaginationEntity? friendsPagination,
    PaginationEntity? receivedPagination,
    PaginationEntity? sentPagination,
  }) {
    return FriendsState(
      submitStatus: submitStatus ?? this.submitStatus,
      queryStatus: queryStatus ?? this.queryStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      friendshipStatus: clearFriendshipStatus ? null : (friendshipStatus ?? this.friendshipStatus),
      friendshipId: clearFriendshipId ? null : (friendshipId ?? this.friendshipId),
      friendStats: friendStats ?? this.friendStats,
      friendsList: friendsList ?? this.friendsList,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      friendsPagination: friendsPagination ?? this.friendsPagination,
      receivedPagination: receivedPagination ?? this.receivedPagination,
      sentPagination: sentPagination ?? this.sentPagination,
    );
  }

  @override
  List<Object?> get props => [
        submitStatus,
        queryStatus,
        errorMessage,
        friendshipStatus,
        friendshipId,
        friendStats,
        friendsList,
        receivedRequests,
        sentRequests,
        friendsPagination,
        receivedPagination,
        sentPagination,
      ];
}

part of 'community_cubit.dart';

class CommunityState extends BaseState {
  final List<NftCommunityEntity> allNftCommunities;
  final int communityCount;
  final int itemCount;
  final List<NftCommunityEntity> hotNftCommunities;
  final List<NftCommunityEntity> userNftCommunities;
  final GetNftCommunityOrderBy allNftCommOrderBy;

  const CommunityState({
    required this.status,
    required this.allNftCommunities,
    required this.communityCount,
    required this.itemCount,
    required this.hotNftCommunities,
    required this.userNftCommunities,
    required this.allNftCommOrderBy,
  });

  @override
  final RequestStatus status;

  factory CommunityState.initial() => const CommunityState(
        status: RequestStatus.initial,
        allNftCommunities: [],
        communityCount: 0,
        itemCount: 0,
        hotNftCommunities: [],
        userNftCommunities: [],
        allNftCommOrderBy: GetNftCommunityOrderBy.points,
      );

  @override
  List<Object?> get props => [
        status,
        allNftCommunities,
        communityCount,
        itemCount,
        hotNftCommunities,
        userNftCommunities,
        allNftCommOrderBy,
      ];

  @override
  String toString() =>
      'CommunityState(status: $status, allNftCommunities: $allNftCommunities, communityCount: $communityCount, itemCount: $itemCount, hotNftCommunities: $hotNftCommunities, userNftCommunities: $userNftCommunities, allNftCommOrderBy: $allNftCommOrderBy)';

  @override
  CommunityState copyWith({
    List<NftCommunityEntity>? allNftCommunities,
    int? communityCount,
    int? itemCount,
    List<NftCommunityEntity>? hotNftCommunities,
    List<NftCommunityEntity>? userNftCommunities,
    RequestStatus? status,
    GetNftCommunityOrderBy? orderBy,
  }) {
    return CommunityState(
      allNftCommunities: allNftCommunities ?? this.allNftCommunities,
      communityCount: communityCount ?? this.communityCount,
      itemCount: itemCount ?? this.itemCount,
      hotNftCommunities: hotNftCommunities ?? this.hotNftCommunities,
      userNftCommunities: userNftCommunities ?? this.userNftCommunities,
      status: status ?? this.status,
      allNftCommOrderBy: orderBy ?? allNftCommOrderBy,
    );
  }
}

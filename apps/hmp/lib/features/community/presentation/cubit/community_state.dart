part of 'community_cubit.dart';

class CommunityState extends BaseState {
  final List<NftCommunityEntity> allNftCommunities;
  final int communityCount;
  final int itemCount;
  final List<NftCommunityEntity> hotNftCommunities;
  final List<NftCommunityEntity> userNftCommunities;
  final GetNftCommunityOrderBy allNftCommOrderBy;
  final int allCommunitiesPage;
  final RequestStatus loadingMoreStatus;
  final bool allNftLoaded;
  @override
  final RequestStatus status;

  const CommunityState({
    required this.status,
    required this.allNftCommunities,
    required this.communityCount,
    required this.itemCount,
    required this.hotNftCommunities,
    required this.userNftCommunities,
    required this.allNftCommOrderBy,
    required this.allCommunitiesPage,
    required this.loadingMoreStatus,
    required this.allNftLoaded,
  });

  factory CommunityState.initial() => const CommunityState(
        status: RequestStatus.initial,
        allNftCommunities: [],
        communityCount: 0,
        itemCount: 0,
        hotNftCommunities: [],
        userNftCommunities: [],
        allNftCommOrderBy: GetNftCommunityOrderBy.points,
        allCommunitiesPage: 1,
        loadingMoreStatus: RequestStatus.initial,
        allNftLoaded: false,
      );

  bool get isLoadingMore => loadingMoreStatus == RequestStatus.loading;

  @override
  List<Object?> get props => [
        status,
        allNftCommunities,
        communityCount,
        itemCount,
        hotNftCommunities,
        userNftCommunities,
        allNftCommOrderBy,
        allCommunitiesPage,
        loadingMoreStatus,
        allNftLoaded,
      ];

  @override
  CommunityState copyWith({
    List<NftCommunityEntity>? allNftCommunities,
    int? communityCount,
    int? itemCount,
    List<NftCommunityEntity>? hotNftCommunities,
    List<NftCommunityEntity>? userNftCommunities,
    GetNftCommunityOrderBy? allNftCommOrderBy,
    int? allCommunitiesPage,
    RequestStatus? loadingMoreStatus,
    bool? allNftLoaded,
    RequestStatus? status,
  }) {
    return CommunityState(
      allNftCommunities: allNftCommunities ?? this.allNftCommunities,
      communityCount: communityCount ?? this.communityCount,
      itemCount: itemCount ?? this.itemCount,
      hotNftCommunities: hotNftCommunities ?? this.hotNftCommunities,
      userNftCommunities: userNftCommunities ?? this.userNftCommunities,
      allNftCommOrderBy: allNftCommOrderBy ?? this.allNftCommOrderBy,
      allCommunitiesPage: allCommunitiesPage ?? this.allCommunitiesPage,
      loadingMoreStatus: loadingMoreStatus ?? this.loadingMoreStatus,
      allNftLoaded: allNftLoaded ?? this.allNftLoaded,
      status: status ?? this.status,
    );
  }
}

part of 'community_rankings_cubit.dart';

class CommunityRankingsState extends BaseState {
  final List<TopCollectionNftEntity> topNfts;
  @override
  final RequestStatus status;
  final int pageSize;
  final int page;
  final RequestStatus loadingMoreStatus;
  final bool isLoadedAll;

  const CommunityRankingsState({
    required this.status,
    required this.topNfts,
    required this.pageSize,
    required this.page,
    required this.loadingMoreStatus,
    required this.isLoadedAll,
  });

  bool get isLoadingMore => loadingMoreStatus == RequestStatus.loading;
  bool get isLoadingMoreFailure => loadingMoreStatus == RequestStatus.failure;
  bool get isLoadingMoreSuccess => loadingMoreStatus == RequestStatus.success;

  factory CommunityRankingsState.initial() => const CommunityRankingsState(
        status: RequestStatus.initial,
        topNfts: [],
        pageSize: 20,
        page: 1,
        loadingMoreStatus: RequestStatus.initial,
        isLoadedAll: false,
      );

  @override
  List<Object?> get props => [
        status,
        topNfts,
        pageSize,
        page,
        loadingMoreStatus,
        isLoadedAll,
      ];

  @override
  CommunityRankingsState copyWith({
    List<TopCollectionNftEntity>? topNfts,
    RequestStatus? status,
    int? pageSize,
    int? page,
    RequestStatus? loadingMoreStatus,
    bool? isLoadedAll,
  }) {
    return CommunityRankingsState(
      topNfts: topNfts ?? this.topNfts,
      status: status ?? this.status,
      pageSize: pageSize ?? this.pageSize,
      page: page ?? this.page,
      loadingMoreStatus: loadingMoreStatus ?? this.loadingMoreStatus,
      isLoadedAll: isLoadedAll ?? this.isLoadedAll,
    );
  }
}

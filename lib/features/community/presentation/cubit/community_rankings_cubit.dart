import 'package:collection/collection.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';

part 'community_rankings_state.dart';

@lazySingleton
class CommunityRankingsCubit extends BaseCubit<CommunityRankingsState> {
  final NftRepository _nftRepository;
  CommunityRankingsCubit(this._nftRepository)
      : super(CommunityRankingsState.initial());

  Future<void> onStart({required TopCollectionNftEntity nftInfo}) async {
    emit(CommunityRankingsState.initial()
        .copyWith(status: RequestStatus.loading));

    onGetTopCollections(nftInfo: nftInfo, loadingMore: false);
  }

  Future<void> onLoadMore({required TopCollectionNftEntity nftInfo}) async {
    emit(state.copyWith(
      loadingMoreStatus: RequestStatus.loading,
      page: (state.loadingMoreStatus == RequestStatus.initial ||
                  state.loadingMoreStatus == RequestStatus.success) &&
              !state.isLoadedAll
          ? state.page + 1
          : state.page,
    ));

    onGetTopCollections(nftInfo: nftInfo, loadingMore: true);
  }

  Future<void> onGetTopCollections({
    required TopCollectionNftEntity nftInfo,
    required bool loadingMore,
  }) async {
    final topNftCommsRes = await _nftRepository.getTopNftColletions(
      pageSize: state.pageSize,
      page: state.page,
    );
    topNftCommsRes.fold(
      (l) => emit(state.copyWith(
        status: RequestStatus.failure,
        loadingMoreStatus:
            loadingMore ? RequestStatus.failure : RequestStatus.initial,
        isLoadedAll: !loadingMore,
      )),
      (data) {
        final List<TopCollectionNftEntity> topNfts = loadingMore
            ? List.from(
                state.topNfts..addAll(data.map((e) => e.toEntity()).toList()))
            : data.map((e) => e.toEntity()).toList();
        emit(state.copyWith(
          topNfts: topNfts
              .mapIndexed((index, element) => element.copyWith(index: index))
              .toList(),
          status: RequestStatus.success,
          loadingMoreStatus:
              loadingMore ? RequestStatus.success : RequestStatus.initial,
          isLoadedAll: loadingMore && data.isEmpty,
        ));
      },
    );
  }
}

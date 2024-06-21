import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';

part 'community_state.dart';

@lazySingleton
class CommunityCubit extends BaseCubit<CommunityState> {
  final NftRepository _nftRepository;
  CommunityCubit(this._nftRepository) : super(CommunityState.initial());

  Future<void> onStart() {
    return Future.wait([
      onGetAllNftCommunities(),
      onGetHotNftCommunities(),
      onGetUserNftCommunities(),
    ]);
  }

  Future<void> onGetAllNftCommunities() async {
    final allNftCommsRes = await _nftRepository.getNftCommunities(
      order: state.allNftCommOrderBy,
    );
    allNftCommsRes.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        allNftCommunities:
            data.allCommunities?.map((e) => e.toEntity()).toList() ?? [],
        communityCount: data.communityCount ?? 0,
        itemCount: data.itemCount ?? 0,
        status: RequestStatus.success,
      )),
    );
  }

  void onOrderByChanged(GetNftCommunityOrderBy? orderBy) {
    if (orderBy == null) return;
    
    emit(state.copyWith(orderBy: orderBy));
    onGetAllNftCommunities();
  }

  Future<void> onGetHotNftCommunities() async {
    final hotNftCommsRes = await _nftRepository.getHotNftCommunities();
    hotNftCommsRes.fold(
      (_) {},
      (data) => emit(state.copyWith(
        hotNftCommunities: data.map((e) => e.toEntity()).toList(),
      )),
    );
  }

  Future<void> onGetUserNftCommunities() async {
    final userNftCommsRes = await _nftRepository.getUserNftCommunities();
    userNftCommsRes.fold(
      (_) {},
      (data) => emit(state.copyWith(
        userNftCommunities: data.map((e) => e.toEntity()).toList(),
      )),
    );
  }
}

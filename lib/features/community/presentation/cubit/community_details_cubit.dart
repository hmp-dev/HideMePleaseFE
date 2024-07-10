import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_network_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';

part 'community_details_state.dart';

@lazySingleton
class CommunityDetailsCubit extends BaseCubit<CommunityDetailsState> {
  final NftRepository _nftRepository;
  CommunityDetailsCubit(this._nftRepository)
      : super(CommunityDetailsState.initial());

  Future<void> onStart({required String tokenAddress}) {
    emit(state.copyWith(status: RequestStatus.loading));

    return Future.wait([
      onGetNftInfo(tokenAddress: tokenAddress),
      onGetNftNetworkInfo(tokenAddress: tokenAddress),
      onGetNftBenefits(tokenAddress: tokenAddress),
      onGetNftMembers(tokenAddress: tokenAddress),
    ]);
  }

  Future<void> onGetNftInfo({required String tokenAddress}) async {
    final allNftCommsRes = await _nftRepository.getNftCollectionInfo(
      tokenAddress: tokenAddress,
    );
    allNftCommsRes.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        nftInfo: data.toEntity(),
        status: RequestStatus.success,
      )),
    );
  }

  Future<void> onGetNftNetworkInfo({required String tokenAddress}) async {
    final hotNftCommsRes =
        await _nftRepository.getNftNetworkInfo(tokenAddress: tokenAddress);
    hotNftCommsRes.fold(
      (err) {
        "inside Error for onGetNftNetworkInfo : $err".log();
      },
      (data) => emit(state.copyWith(
        nftNetworkInfo: data.toEntity(),
      )),
    );
  }

  Future<void> onGetNftBenefits({required String tokenAddress}) async {
    final position = await Geolocator.getCurrentPosition();

    final userNftCommsRes = await _nftRepository.getNftBenefits(
      tokenAddress: tokenAddress,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    userNftCommsRes.fold(
      (_) {},
      (data) => emit(state.copyWith(
        nftBenefits: data.benefits?.map((e) => e.toEntity()).toList() ?? [],
        benefitCount: data.benefitCount,
      )),
    );
  }

  Future<void> onGetNftMembers({required String tokenAddress}) async {
    emit(state.copyWith(membersStatus: RequestStatus.loading));

    final userNftCommsRes = await _nftRepository.getNftMembers(
      tokenAddress: tokenAddress,
    );
    userNftCommsRes.fold(
      (_) => emit(state.copyWith(membersStatus: RequestStatus.failure)),
      (data) => emit(state.copyWith(
        communityMembers: data.members?.map((e) => e.toEntity()).toList() ?? [],
        membersCount: data.nftMemberCount,
        membersStatus: RequestStatus.success,
      )),
    );
  }
}

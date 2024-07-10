import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';

part 'membership_state.dart';

@lazySingleton
class MembershipCubit extends BaseCubit<MembershipState> {
  final NftRepository _nftRepository;

  MembershipCubit(
    this._nftRepository,
  ) : super(MembershipState.initial());

  Future<void> onStart({String? userId}) =>
      onGetSelectedNftTokens(userId: userId);

  Future<void> onGetSelectedNftTokens({String? userId}) async {
    final response =
        await _nftRepository.getSelectNftCollections(userId: userId);

    response.fold(
      (err) {
        emit(state.copyWith(status: RequestStatus.failure));
      },
      (selectedNftTokensList) {
        final resultList =
            selectedNftTokensList.map((e) => e.toEntity()).toList();

        emit(
          state.copyWith(
            selectedNftTokensList: resultList,
            status: RequestStatus.success,
          ),
        );
      },
    );
  }
}

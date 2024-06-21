import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';
import 'package:mobile/features/nft/domain/repositories/nft_repository.dart';

part 'points_state.dart';

@lazySingleton
class PointsCubit extends BaseCubit<PointsState> {
  final NftRepository _nftRepository;

  PointsCubit(
    this._nftRepository,
  ) : super(PointsState.initial());

  Future<void> onStart({String? userId}) => onGetNftPoints(userId: userId);

  Future<void> onGetNftPoints({String? userId}) async {
    final response = await _nftRepository.getNftPoints();

    response.fold(
      (err) {
        emit(state.copyWith(status: RequestStatus.failure));
      },
      (nftPointsList) {
        final resultList = nftPointsList
            .map((e) => e.toEntity())
            .toList()
            .where((element) => element.totalPoints > 0)
            .toList();

        emit(
          state.copyWith(
              nftPointsList: resultList, status: RequestStatus.success),
        );
      },
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/common/domain/entities/connected_wallet_entity.dart';
import 'package:mobile/features/home/domain/repositories/wallets_repository.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'wallets_state.dart';

@lazySingleton
class WalletsCubit extends BaseCubit<WalletsState> {
  final WalletsRepository _walletsRepository;

  WalletsCubit(
    this._walletsRepository,
  ) : super(WalletsState.initial());

  Future<void> onGetAllWallets() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _walletsRepository.getWallets();

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      // users.map((e) => e.toEntity()).toList()
      (wallets) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            connectedWallets: wallets.map((e) => e.toEntity()).toList(),
          ),
        );
      },
    );
  }

  Future<void> onPostWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _walletsRepository.saveWallet(
        saveWalletRequestDto: saveWalletRequestDto);

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (wallets) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
        // fetch All Wallets
        onGetAllWallets();
      },
    );
  }
}

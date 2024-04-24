import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/home/domain/repositories/wallets_repository.dart';
import 'package:mobile/features/home/infrastructure/data_sources/wallets_remote_data_source.dart';
import 'package:mobile/features/common/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_wallet_request_dto.dart';

@LazySingleton(as: WalletsRepository)
class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource _remoteDataSource;

  const WalletsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<HMPError, List<ConnectedWalletDto>>> getWallets() async {
    try {
      final response = await _remoteDataSource.getAllConnectedWallets();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, ConnectedWalletDto>> saveWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    try {
      final response = await _remoteDataSource.saveConnectedWallet(
          saveWalletRequestDto: saveWalletRequestDto);
      return right(response);
    } on DioException catch (e, t) {
      Map<String, dynamic> responseMap =
          e.response?.data as Map<String, dynamic>;
      String errorMessage = responseMap['message'];
      if (errorMessage.contains('nUnique constraint failed on the fields')) {
        return left(HMPError.fromNetwork(
          message: "Wallet already exists",
          error: e,
          trace: t,
        ));
      }

      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}

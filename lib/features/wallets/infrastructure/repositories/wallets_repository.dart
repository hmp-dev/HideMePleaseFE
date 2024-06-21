import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/wallet_add_error_dto.dart';

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
      "inside DioException $e".log();

      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } on WalletAddErrorDto catch (e) {
      "inside Catch BenefitRedeemErrorDto $e".log();
      final error = e;
      return left(HMPError.fromNetwork(
        message: error.message,
        error: error.code,
      ));
    } catch (e, t) {
      "inside Catch $e".log();
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, bool>> deleteConnectedWallet(
      {required String walletId}) async {
    try {
      final response =
          await _remoteDataSource.deleteConnectedWallet(walletId: walletId);
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
}

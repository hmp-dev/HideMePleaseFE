import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/wallets/domain/repositories/wallets_repository.dart';
import 'package:mobile/features/wallets/infrastructure/data_sources/wallets_remote_data_source.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/wallet_add_error_dto.dart';

@LazySingleton(as: WalletsRepository)

/// [WalletsRepository] implementation using [WalletsRemoteDataSource].
class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsRemoteDataSource _remoteDataSource;

  /// Constructs a [WalletsRepositoryImpl] instance.
  ///
  /// Parameters:
  /// - [remoteDataSource]: The remote data source used to fetch wallets data.
  const WalletsRepositoryImpl(this._remoteDataSource);

  @override

  /// Fetches all connected wallets from the remote data source.
  ///
  /// Returns a [Future] that completes with a [Either] containing either a
  /// [List] of [ConnectedWalletDto] or a [HMPError].
  Future<Either<HMPError, List<ConnectedWalletDto>>> getWallets() async {
    try {
      final response = await _remoteDataSource.getAllConnectedWallets();
      return right(response);
    } on DioException catch (e, t) {
      // If a DioException occurs, return a [HMPError] from the network.
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      // If an unknown exception occurs, return a [HMPError] from unknown.
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override

  /// Saves a connected wallet to the remote data source.
  ///
  /// Parameters:
  /// - [saveWalletRequestDto]: The DTO containing data for the wallet to be saved.
  ///
  /// Returns a [Future] that completes with a [Either] containing either a
  /// [ConnectedWalletDto] or a [HMPError].
  Future<Either<HMPError, ConnectedWalletDto>> saveWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    try {
      final response = await _remoteDataSource.saveConnectedWallet(
          saveWalletRequestDto: saveWalletRequestDto);
      return right(response);
    } on DioException catch (e, t) {
      // If a DioException occurs, return a [HMPError] from the network.
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } on WalletAddErrorDto catch (e) {
      // If a WalletAddErrorDto occurs, return a [HMPError] from the network.
      final error = e;
      return left(HMPError.fromNetwork(
        code: error.code,
        message: error.message,
        error: error.error,
      ));
    } catch (e, t) {
      // If an unknown exception occurs, return a [HMPError] from unknown.
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override

  /// Deletes a connected wallet from the remote data source.
  ///
  /// Parameters:
  /// - [walletId]: The ID of the wallet to be deleted.
  ///
  /// Returns a [Future] that completes with a [Either] containing either a
  /// [bool] or a [HMPError].
  Future<Either<HMPError, bool>> deleteConnectedWallet(
      {required String walletId}) async {
    try {
      final response =
          await _remoteDataSource.deleteConnectedWallet(walletId: walletId);
      return right(response);
    } on DioException catch (e, t) {
      // If a DioException occurs, return a [HMPError] from the network.
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      // If an unknown exception occurs, return a [HMPError] from unknown.
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}

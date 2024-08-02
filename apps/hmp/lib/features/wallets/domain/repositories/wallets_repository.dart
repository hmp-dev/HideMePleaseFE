import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';

/// Defines the contract for the Wallets repository.
///
/// This abstract class exposes methods for interacting with the Wallets
/// feature's data layer.
abstract class WalletsRepository {
  /// Retrieves all connected wallets.
  ///
  /// Returns a [Future] that completes with a [Either] object. If the
  /// operation is successful, it contains a [List] of [ConnectedWalletDto]
  /// objects. If it fails, it contains a [HMPError] object.
  Future<Either<HMPError, List<ConnectedWalletDto>>> getWallets();

  /// Saves a connected wallet.
  ///
  /// The [saveWalletRequestDto] parameter contains the data of the wallet to
  /// be saved.
  ///
  /// Returns a [Future] that completes with a [Either] object. If the
  /// operation is successful, it contains a [ConnectedWalletDto] object.
  /// If it fails, it contains a [HMPError] object.
  Future<Either<HMPError, ConnectedWalletDto>> saveWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  });

  /// Deletes a connected wallet.
  ///
  /// The [walletId] parameter contains the ID of the wallet to be deleted.
  ///
  /// Returns a [Future] that completes with a [Either] object. If the
  /// operation is successful, it contains a [bool] value indicating the
  /// deletion result. If it fails, it contains a [HMPError] object.
  Future<Either<HMPError, bool>> deleteConnectedWallet({
    required String walletId,
  });
}

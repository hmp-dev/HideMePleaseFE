import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/wallet_add_error_dto.dart';

@lazySingleton

/// Class responsible for making network requests to the wallet endpoints.
class WalletsRemoteDataSource {
  final Network _network;

  /// Creates a new instance of [WalletsRemoteDataSource].
  ///
  /// The [_network] parameter is responsible for making the actual network requests.
  WalletsRemoteDataSource(this._network);

  /// Saves a connected wallet to the server.
  ///
  /// Throws a [WalletAddErrorDto] if the wallet already exists or if there is
  /// any other error.
  ///
  /// The [saveWalletRequestDto] parameter contains the data to be sent in the request body.
  ///
  /// Returns a [ConnectedWalletDto] object representing the saved wallet.
  Future<ConnectedWalletDto> saveConnectedWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    try {
      // Make a POST request to the wallet endpoint with the save wallet request data
      final response =
          await _network.post("wallet", saveWalletRequestDto.toJson());

      // Convert the response data to a ConnectedWalletDto object and return it
      return ConnectedWalletDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e, t) {
      if (e.response != null && e.response?.statusCode == 409) {
        final Map<String, dynamic> responseBody = e.response?.data;
        final errorMessage = responseBody['message'] ?? 'Wallet already exists';
        final errorCode = responseBody['error'] ?? 'CONFLICT';

        // Throw a custom error if the wallet already exists
        throw WalletAddErrorDto(
          code: 409,
          message: errorMessage,
          error: errorCode,
          trace: t.toString(),
        );
      }

      // Throw a custom error for any other error
      throw WalletAddErrorDto(
        message: e.message ?? "",
        error: e.toString(),
        trace: t.toString(),
      );
    } catch (e, t) {
      // Throw a generic error
      throw WalletAddErrorDto(
        message: e.toString(),
        error: e.toString(),
        trace: t.toString(),
      );
    }
  }

  /// Retrieves all connected wallets from the server.
  ///
  /// Returns a list of [ConnectedWalletDto] objects representing the connected wallets.
  Future<List<ConnectedWalletDto>> getAllConnectedWallets() async {
    final response = await _network.get("wallet", {});

    // Convert the response data to a list of ConnectedWalletDto objects and return it
    return response.data
        .map<ConnectedWalletDto>(
            (e) => ConnectedWalletDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Deletes a connected wallet from the server.
  ///
  /// The [walletId] parameter is the ID of the wallet to be deleted.
  ///
  /// Returns `true` if the wallet was successfully deleted, `false` otherwise.
  Future<bool> deleteConnectedWallet({
    required String walletId,
  }) async {
    final response =
        await _network.request("wallet/id/$walletId", "DELETE", {});

    // Log the response status code and data
    "response is: ${response.statusCode}".log();
    "response is: ${response.data}".log();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

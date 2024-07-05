import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/save_wallet_request_dto.dart';
import 'package:mobile/features/wallets/infrastructure/dtos/wallet_add_error_dto.dart';

@lazySingleton
class WalletsRemoteDataSource {
  final Network _network;

  WalletsRemoteDataSource(this._network);

  Future<ConnectedWalletDto> saveConnectedWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    try {
      final response =
          await _network.post("wallet", saveWalletRequestDto.toJson());

      return ConnectedWalletDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e, t) {
      if (e.response != null && e.response?.statusCode == 409) {
        final Map<String, dynamic> responseBody = e.response?.data;
        final errorCode = responseBody['error']['code'];
        final errorMessage = responseBody['error']['message'];

        throw WalletAddErrorDto(
          message: errorMessage,
          error: errorCode,
          trace: t.toString(),
        );
      }

      throw WalletAddErrorDto(
        message: e.message ?? "",
        error: e.toString(),
        trace: t.toString(),
      );
    } catch (e, t) {
      throw WalletAddErrorDto(
        message: e.toString(),
        error: e.toString(),
        trace: t.toString(),
      );
    }
  }

  Future<List<ConnectedWalletDto>> getAllConnectedWallets() async {
    final response = await _network.get("wallet", {});

    return response.data
        .map<ConnectedWalletDto>(
            (e) => ConnectedWalletDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> deleteConnectedWallet({
    required String walletId,
  }) async {
    final response =
        await _network.request("wallet/id/$walletId", "DELETE", {});

    "response is: ${response.statusCode}".log();
    "response is: ${response.data}".log();

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}

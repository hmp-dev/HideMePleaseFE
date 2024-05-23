import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_wallet_request_dto.dart';

@lazySingleton
class WalletsRemoteDataSource {
  final Network _network;

  WalletsRemoteDataSource(this._network);

  Future<ConnectedWalletDto> saveConnectedWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  }) async {
    final response =
        await _network.post("wallet", saveWalletRequestDto.toJson());

    return ConnectedWalletDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ConnectedWalletDto>> getAllConnectedWallets() async {
    final response = await _network.get("wallet", {});

    "getAllConnectedWallets: ${response.data}".log();
    return response.data
        .map<ConnectedWalletDto>(
            (e) => ConnectedWalletDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/home/infrastructure/dtos/connected_wallet_dto.dart';
import 'package:mobile/features/home/infrastructure/dtos/save_wallet_request_dto.dart';

abstract class WalletsRepository {
  Future<Either<HMPError, List<ConnectedWalletDto>>> getWallets();
  Future<Either<HMPError, ConnectedWalletDto>> saveWallet({
    required SaveWalletRequestDto saveWalletRequestDto,
  });
}

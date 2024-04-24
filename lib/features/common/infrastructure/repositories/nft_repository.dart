import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/features/common/infrastructure/datasources/nft_remote_data_source.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';

@LazySingleton(as: NftRepository)
class NftRepositoryImpl extends NftRepository {
  final NftRemoteDataSource _nftRemoteDataSource;

  NftRepositoryImpl(this._nftRemoteDataSource);

  @override
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections() async {
    try {
      final response = await _nftRemoteDataSource.getAllConnectedWallets();
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
  Future<Either<HMPError, bool>> postNftSelectDeselectToken({
    required SelectTokenToggleRequestDto selectTokenToggleRequestDto,
  }) async {
    try {
      final response = await _nftRemoteDataSource.postTokenSelectDeselect(
          selectTokenToggleRequestDto: selectTokenToggleRequestDto);
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
  Future<Either<HMPError, List<SelectedNFTDto>>>
      getSelectNftTokensList() async {
    try {
      final response = await _nftRemoteDataSource.getSelectTokens();
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

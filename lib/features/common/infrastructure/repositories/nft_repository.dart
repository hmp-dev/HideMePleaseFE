import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/common/domain/repositories/nft_repository.dart';
import 'package:mobile/features/common/infrastructure/datasources/nft_remote_data_source.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_benefit_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collections_group_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_network_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_points_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_usage_history_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/selected_nft_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/welcome_nft_dto.dart';

@LazySingleton(as: NftRepository)
class NftRepositoryImpl extends NftRepository {
  final NftRemoteDataSource _nftRemoteDataSource;

  NftRepositoryImpl(this._nftRemoteDataSource);

  @override
  Future<Either<HMPError, NftCollectionsGroupDto>> getNftCollections({
    String? chain,
    String? nextCursor,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftCollections(
        chain: chain,
        nextCursor: nextCursor,
      );
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
      getSelectNftCollections() async {
    try {
      final response = await _nftRemoteDataSource.requestGetSelectTokens();
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
  Future<Either<HMPError, bool>> postCollectionOrderSave({
    required SaveSelectedTokensReorderRequestDto
        saveSelectedTokensReorderRequestDto,
  }) async {
    try {
      final response = await _nftRemoteDataSource
          .saveCollectionsSelectedOrder(saveSelectedTokensReorderRequestDto);

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
  Future<Either<HMPError, WelcomeNftDto>> getWelcomeNft() async {
    try {
      final response = await _nftRemoteDataSource.requestGetWelcomeNFT();
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
  Future<Either<HMPError, String>> getConsumeUserWelcomeNft(
      {required int welcomeNftId}) async {
    try {
      final response =
          await _nftRemoteDataSource.requestGetConsumeWelcomeNft(welcomeNftId);
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
  Future<Either<HMPError, List<NftBenefitDto>>> getNftBenefits({
    required String tokenAddress,
    String? spaceId,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftBenefits(
        tokenAddress: tokenAddress,
        spaceId: spaceId,
        pageSize: pageSize,
        page: page,
      );
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
  Future<Either<HMPError, List<NftPointsDto>>> getNftPoints() async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftPoints();
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
  Future<Either<HMPError, NftNetworkDto>> getNftNetworkInfo(
      {required String tokenAddress}) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftNetworkInfo(
        tokenAddress: tokenAddress,
      );
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
  Future<Either<HMPError, NftUsageHistoryDto>> getNftUsageHistory({
    required String tokenAddress,
    String? order,
    String? page,
    String? type,
  }) async {
    try {
      final response = await _nftRemoteDataSource.requestGetNftUsageHistory(
        tokenAddress: tokenAddress,
      );
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

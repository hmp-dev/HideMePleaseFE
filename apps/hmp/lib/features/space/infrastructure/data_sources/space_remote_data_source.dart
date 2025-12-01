import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/app/core/notifications/notification_service.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefit_redeem_error_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/benefits_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_status_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_out_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/new_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/recommendation_space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_detail_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/spaces_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_users_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/current_group_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/top_used_nft_dto.dart';

@lazySingleton
class SpaceRemoteDataSource {
  final Network _network;

  SpaceRemoteDataSource(this._network);

  // Fetches the list of nearby spaces for a given token address and location.
  Future<SpacesResponseDto> getNearBySpacesList({
    required String tokenAddress,
    required double latitude,
    required double longitude,
  }) async {
    final Map<String, String> queryParams = {
      'latitude': '$latitude',
      'longitude': '$longitude',
    };

    final response =
        await _network.get("nft/collection/$tokenAddress/spaces", queryParams);

    return SpacesResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  // Fetches the backdoor token for a given space ID.
  Future<String> getBackdoorToken({required String spaceId}) async {
    final response =
        await _network.get("space/benefits/token-backdoor/$spaceId", {});

    return response.data;
  }

  // Attempts to redeem a benefit for a given benefit ID, token address, space ID, and location.
  Future<bool> postRedeemBenefit({
    required String benefitId,
    required String tokenAddress,
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        "latitude": latitude,
        "longitude": longitude,
        'spaceId': spaceId,
        'tokenAddress': tokenAddress,
      };

      final response =
          await _network.post("space/benefits/redeem/$benefitId", queryParams);

      if (response.statusCode == 204) {
        return true;
      }

      return false;
    } on DioException catch (e, t) {
      if (e.response != null && e.response?.statusCode == 400) {
        final Map<String, dynamic> responseBody = e.response?.data;
        final errorCode = responseBody['error']['code'];
        final errorMessage = responseBody['error']['message'];

        throw BenefitRedeemErrorDto(
          message: errorMessage,
          error: errorCode,
          trace: t.toString(),
        );
      }

      throw BenefitRedeemErrorDto(
        message: e.message ?? "",
        error: e.toString(),
        trace: t.toString(),
      );
    } catch (e, t) {
      throw BenefitRedeemErrorDto(
        message: e.toString(),
        error: e.toString(),
        trace: t.toString(),
      );
    }
  }

  // Fetches the list of top used NFTs.
  Future<List<TopUsedNftDto>> requestGetTopUsedNfts() async {
    final response = await _network.get("nft/collections", {});
    return response.data
        .map<TopUsedNftDto>(
            (e) => TopUsedNftDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Fetches the list of new spaces.
  Future<List<NewSpaceDto>> requestGetNewSpaceList() async {
    final response = await _network.get("space/new-spaces", {});
    return response.data
        .map<NewSpaceDto>(
            (e) => NewSpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Fetches the list of spaces for a given category, page, and location.
  Future<List<SpaceDto>> requestGetSpaceList({
    String? category,
    int? page,
    required double latitude,
    required double longitude,
  }) async {
    final Map<String, String> queryParams = {
      if (category != null) 'category': category,
      if (page != null) 'page': page.toString(),
      "latitude": '$latitude',
      "longitude": '$longitude',
    };

    final response = await _network.get("space", queryParams);

    final List<SpaceDto> spaces = response.data
        .map<SpaceDto>((e) => SpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return spaces;
  }

  // Fetches the list of recommended spaces.
  Future<List<RecommendationSpaceDto>> requestGetRecommendedSpaces() async {
    final response = await _network.get("space/recommendations", {});
    return response.data
        .map<RecommendationSpaceDto>(
            (e) => RecommendationSpaceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Fetches the details of a space for a given space ID.
  Future<SpaceDetailDto> requestGetSpaceDetailBySpaceId(
      {required String spaceId}) async {
    final response = await _network.get("space/space/$spaceId", {});
    return SpaceDetailDto.fromJson(response.data as Map<String, dynamic>);
  }

  // Fetches the benefits group for a given space ID.
  Future<BenefitsGroupDto> requestGetSpaceBenefits(
      {required String spaceId}) async {
    final response = await _network.get("space/space/$spaceId/benefits", {});
    return BenefitsGroupDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckInResponseDto> checkIn({
    required String spaceId,
    required double latitude,
    required double longitude,
    String? benefitId,
  }) async {
    final Map<String, dynamic> data = {
      'latitude': latitude,
      'longitude': longitude,
    };

    // Add benefitId if provided
    if (benefitId != null && benefitId.isNotEmpty) {
      data['benefitId'] = benefitId;
      print('🎁 Check-in with benefit: $benefitId');
    }

    // Add FCM token for Silent Push heartbeat mechanism
    try {
      final fcmToken = await NotificationServices.instance.getDeviceToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcmToken'] = fcmToken;
        print('📱 Check-in with FCM token for Silent Push heartbeat');
      } else {
        print('⚠️ FCM token is null or empty, check-in without token');
      }
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
      // Continue with check-in even if FCM token retrieval fails
    }

    final response =
        await _network.post("space/$spaceId/check-in", data);
    return CheckInResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckInStatusDto> getCheckInStatus(
      {required String spaceId}) async {
    final response = await _network.get("space/$spaceId/check-in-status", {});
    print('✅ Raw Check-In Status Response: ${response.data}');
    return CheckInStatusDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckInUsersResponseDto> getCheckInUsers(
      {required String spaceId}) async {
    print('📡 Calling getCheckInUsers for spaceId: $spaceId');
    final response = await _network.get("space/$spaceId/check-in-users", {});
    print('✅ Raw getCheckInUsers Response: ${response.data}');
    return CheckInUsersResponseDto.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<CurrentGroupDto> getCurrentGroup({required String spaceId}) async {
    final response =
        await _network.get("space/$spaceId/current-group", {});
    return CurrentGroupDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CheckOutResponseDto> checkOut({required String spaceId}) async {
    final response = await _network.request(
      "space/$spaceId/check-out",
      "DELETE",
      null,
    );
    return CheckOutResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
  
  // Sends a heartbeat to maintain active check-in status
  Future<void> sendCheckInHeartbeat({
    required String spaceId,
    required double latitude,
    required double longitude,
  }) async {
    final Map<String, dynamic> body = {
      'spaceId': spaceId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    
    print('💓 Sending heartbeat for space: $spaceId');
    await _network.post("space/checkin/heartbeat", body);
    print('✅ Heartbeat sent successfully');
  }
  
  // Gets the current user's check-in status
  Future<CheckInStatusDto> getCurrentUserCheckInStatus() async {
    print('🔍 Fetching current user check-in status');
    final response = await _network.get("space/checkin/status", {});
    print('✅ Check-in status retrieved');
    return CheckInStatusDto.fromJson(response.data as Map<String, dynamic>);
  }
}

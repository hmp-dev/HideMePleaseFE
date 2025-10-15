import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_list_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_create_response_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_stats_dto.dart';

@lazySingleton
class SirenRemoteDataSource {
  final Network _network;

  SirenRemoteDataSource(this._network);

  /// POST /space/siren - 사이렌 생성
  Future<SirenCreateResponseDto> createSiren({
    required String spaceId,
    required String message,
    required String expiresAt,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'spaceId': spaceId,
        'message': message,
        'expiresAt': expiresAt,
      };

      final response = await _network.post('space/siren', body);
      return SirenCreateResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // 400 에러의 경우 서버에서 온 메시지 추출
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? '알 수 없는 오류가 발생했습니다';
        throw HMPError.fromApi(
          code: e.response?.statusCode,
          message: errorMessage,
          error: e.response?.data,
        );
      }
      rethrow;
    }
  }

  /// GET /space/siren - 사이렌 목록 조회
  Future<SirenListResponseDto> getSirenList({
    String sortBy = 'time', // 'distance' or 'time'
    double? latitude,
    double? longitude,
    int page = 1,
    int limit = 20,
    String? spaceId,
  }) async {
    final Map<String, String> queryParams = {
      'sortBy': sortBy,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (latitude != null) {
      queryParams['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      queryParams['longitude'] = longitude.toString();
    }
    if (spaceId != null && spaceId.isNotEmpty) {
      queryParams['spaceId'] = spaceId;
    }

    print('🌐 [SirenAPI] GET /space/siren - sortBy: $sortBy, lat: $latitude, lng: $longitude');
    final response = await _network.get('space/siren', queryParams);
    final dto = SirenListResponseDto.fromJson(response.data as Map<String, dynamic>);
    print('✅ [SirenAPI] Received ${dto.toEntity().sirens.length} sirens');
    return dto;
  }

  /// GET /space/siren/my - 내 사이렌 목록
  Future<SirenListResponseDto> getMySirenList() async {
    final response = await _network.get('space/siren/my', {});
    return SirenListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /space/siren/:sirenId - 사이렌 삭제
  Future<bool> deleteSiren({required String sirenId}) async {
    try {
      final response = await _network.request('space/siren/$sirenId', 'DELETE', null);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('❌ Delete siren error: $e');
      return false;
    } catch (e) {
      print('❌ Delete siren error: $e');
      return false;
    }
  }

  /// GET /space/siren/stats/:spaceId - 매장별 사이렌 통계
  Future<SirenStatsDto> getSirenStats({required String spaceId}) async {
    final response = await _network.get('space/siren/stats/$spaceId', {});
    return SirenStatsDto.fromJson(response.data as Map<String, dynamic>);
  }
}

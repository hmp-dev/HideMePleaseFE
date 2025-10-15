import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_list_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_request_response_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_stats_dto.dart';

@lazySingleton
class FriendsRemoteDataSource {
  final Network _network;

  FriendsRemoteDataSource(this._network);

  /// POST /friends/request - 친구 신청 보내기
  Future<Map<String, dynamic>> sendFriendRequest({
    required String addresseeId,
  }) async {
    final Map<String, dynamic> body = {
      'addresseeId': addresseeId,
    };

    final response = await _network.post('friends/request', body);
    return response.data as Map<String, dynamic>;
  }

  /// POST /friends/accept/:friendshipId - 친구 신청 수락
  Future<Map<String, dynamic>> acceptFriendRequest({
    required String friendshipId,
  }) async {
    final response = await _network.post('friends/accept/$friendshipId', {});
    return response.data as Map<String, dynamic>;
  }

  /// POST /friends/reject/:friendshipId - 친구 신청 거절
  Future<Map<String, dynamic>> rejectFriendRequest({
    required String friendshipId,
  }) async {
    final response = await _network.post('friends/reject/$friendshipId', {});
    return response.data as Map<String, dynamic>;
  }

  /// GET /friends - 친구 목록 조회
  Future<FriendListResponseDto> getFriendsList({
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _network.get('friends', queryParams);
    return FriendListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /friends/requests/received - 받은 친구 신청 목록
  Future<FriendRequestResponseDto> getReceivedFriendRequests({
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _network.get('friends/requests/received', queryParams);
    return FriendRequestResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /friends/requests/sent - 보낸 친구 신청 목록
  Future<FriendRequestResponseDto> getSentFriendRequests({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _network.get('friends/requests/sent', queryParams);
    return FriendRequestResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /friends/:friendshipId - 친구 삭제
  Future<bool> deleteFriend({required String friendshipId}) async {
    try {
      final response = await _network.request('friends/$friendshipId', 'DELETE', null);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('❌ Delete friend error: $e');
      return false;
    } catch (e) {
      print('❌ Delete friend error: $e');
      return false;
    }
  }

  /// POST /friends/block/:userId - 사용자 차단
  Future<Map<String, dynamic>> blockUser({required String userId}) async {
    final response = await _network.post('friends/block/$userId', {});
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /friends/block/:userId - 차단 해제
  Future<Map<String, dynamic>> unblockUser({required String userId}) async {
    final response = await _network.request('friends/block/$userId', 'DELETE', null);
    return response.data as Map<String, dynamic>;
  }

  /// GET /friends/search - 친구 검색
  Future<FriendListResponseDto> searchFriends({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, String> queryParams = {
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _network.get('friends/search', queryParams);
    return FriendListResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /friends/stats - 친구 통계 조회
  Future<FriendStatsDto> getFriendStats() async {
    final response = await _network.get('friends/stats', {});
    return FriendStatsDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /friends/status/:userId - 특정 사용자와의 친구 관계 상태 조회
  Future<Map<String, dynamic>?> getFriendshipStatus({required String userId}) async {
    try {
      final response = await _network.get('friends/status/$userId', {});
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      // 404인 경우 친구 관계가 없음
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}

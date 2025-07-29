import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/space/infrastructure/dtos/event_category_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_dto.dart';

@lazySingleton
class EventCategoryRemoteDataSource {
  final Network _network;

  EventCategoryRemoteDataSource(this._network);

  Future<List<EventCategoryDto>> getEventCategories({
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (includeInactive) {
        queryParams['includeInactive'] = includeInactive.toString();
      }

      print('🚨🚨🚨 EVENT CATEGORY API: Calling GET /event-category with params: $queryParams');
      print('🚨🚨🚨 EVENT CATEGORY API: Network instance: $_network');
      print('🚨🚨🚨 EVENT CATEGORY API: Dio instance: ${_network.dio}');
      
      final response = await _network.get(
        'event-category',
        queryParams,
      );

      print('🚨🚨🚨 EVENT CATEGORY API Response Status: ${response.statusCode}');
      print('🚨🚨🚨 EVENT CATEGORY API Response Data: ${response.data}');
      
      if (response.data == null) {
        print('🚨🚨🚨 EVENT CATEGORY API WARNING: Response data is null');
        return [];
      }
      
      if (response.data is List) {
        final categories = (response.data as List)
            .map((e) => EventCategoryDto.fromJson(e as Map<String, dynamic>))
            .toList();
        print('🚨🚨🚨 EVENT CATEGORY API: Parsed ${categories.length} event categories');
        return categories;
      }
      print('🚨🚨🚨 EVENT CATEGORY API WARNING: returned non-list data, type: ${response.data.runtimeType}');
      return [];
    } catch (e, stackTrace) {
      print('🚨🚨🚨 EVENT CATEGORY API ERROR: $e');
      print('🚨🚨🚨 EVENT CATEGORY API ERROR Type: ${e.runtimeType}');
      if (e is DioError) {
        print('🚨🚨🚨 EVENT CATEGORY API DioError response: ${e.response}');
        print('🚨🚨🚨 EVENT CATEGORY API DioError status: ${e.response?.statusCode}');
        print('🚨🚨🚨 EVENT CATEGORY API DioError data: ${e.response?.data}');
        
        // API 오류 상세 로깅
        if (e.response?.statusCode == 404) {
          print('🚨🚨🚨 EVENT CATEGORY API: Endpoint not found (404)');
        } else if (e.response?.statusCode == 400) {
          print('🚨🚨🚨 EVENT CATEGORY API: Bad request (400)');
        } else if (e.response?.statusCode == 401) {
          print('🚨🚨🚨 EVENT CATEGORY API: Unauthorized (401)');
        } else if (e.response?.statusCode == 500) {
          print('🚨🚨🚨 EVENT CATEGORY API: Server error (500)');
        }
      }
      print('🚨🚨🚨 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<EventCategoryDto> getEventCategoryById({
    required String id,
  }) async {
    try {
      final response = await _network.get(
        'event-category/$id',
        {},
      );

      return EventCategoryDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SpaceDto>> getSpacesByEventCategory({
    required String eventCategoryId,
  }) async {
    try {
      final response = await _network.get(
        'event-category/$eventCategoryId/spaces',
        {},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((e) => SpaceDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/domain/repositories/event_category_repository.dart';
import 'package:mobile/features/space/infrastructure/data_sources/event_category_remote_data_source.dart';

@LazySingleton(as: EventCategoryRepository)
class EventCategoryRepositoryImpl implements EventCategoryRepository {
  final EventCategoryRemoteDataSource _remoteDataSource;

  EventCategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<HMPError, List<EventCategoryEntity>>> getEventCategories({
    bool includeInactive = false,
  }) async {
    try {
      print('🚨🚨🚨 EVENT CATEGORY REPO: Calling getEventCategories');
      final result = await _remoteDataSource.getEventCategories(
        includeInactive: includeInactive,
      );
      print('🚨🚨🚨 EVENT CATEGORY REPO: Got ${result.length} DTOs from data source');
      final entities = result.map((dto) => dto.toEntity()).toList();
      print('🚨🚨🚨 EVENT CATEGORY REPO: Converted to ${entities.length} entities');
      return Right(entities);
    } catch (e, stackTrace) {
      print('🚨🚨🚨 EVENT CATEGORY REPO ERROR: $e');
      print('🚨🚨🚨 EVENT CATEGORY REPO ERROR Type: ${e.runtimeType}');
      
      return Left(HMPError(
        type: ErrorType.server,
        message: 'Failed to load event categories: ${e.toString()}',
        error: e.toString(),
        trace: stackTrace.toString(),
      ));
    }
  }

  @override
  Future<Either<HMPError, EventCategoryEntity>> getEventCategoryById({
    required String id,
  }) async {
    try {
      final result = await _remoteDataSource.getEventCategoryById(id: id);
      return Right(result.toEntity());
    } catch (e) {
      return Left(HMPError(
        type: ErrorType.server,
        message: e.toString(),
        error: e.toString(),
        trace: e.toString(),
      ));
    }
  }

  @override
  Future<Either<HMPError, List<SpaceEntity>>> getSpacesByEventCategory({
    required String eventCategoryId,
  }) async {
    try {
      final result = await _remoteDataSource.getSpacesByEventCategory(
        eventCategoryId: eventCategoryId,
      );
      return Right(result.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(HMPError(
        type: ErrorType.server,
        message: e.toString(),
        error: e.toString(),
        trace: e.toString(),
      ));
    }
  }
}
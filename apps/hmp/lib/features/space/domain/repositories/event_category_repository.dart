import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';

abstract class EventCategoryRepository {
  Future<Either<HMPError, List<EventCategoryEntity>>> getEventCategories({
    bool includeInactive = false,
  });
  
  Future<Either<HMPError, EventCategoryEntity>> getEventCategoryById({
    required String id,
  });
  
  Future<Either<HMPError, List<SpaceEntity>>> getSpacesByEventCategory({
    required String eventCategoryId,
  });
}
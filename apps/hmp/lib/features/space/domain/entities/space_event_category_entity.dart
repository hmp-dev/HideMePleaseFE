import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';

class SpaceEventCategoryEntity extends Equatable {
  final EventCategoryEntity eventCategory;

  const SpaceEventCategoryEntity({
    required this.eventCategory,
  });

  @override
  List<Object?> get props => [eventCategory];

  SpaceEventCategoryEntity copyWith({
    EventCategoryEntity? eventCategory,
  }) {
    return SpaceEventCategoryEntity(
      eventCategory: eventCategory ?? this.eventCategory,
    );
  }
}
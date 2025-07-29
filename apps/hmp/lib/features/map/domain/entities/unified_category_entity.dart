import 'package:equatable/equatable.dart';
import 'package:mobile/app/core/enum/space_category.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';

enum CategoryType {
  space,
  event,
}

class UnifiedCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final CategoryType type;
  final SpaceCategory? spaceCategory;
  final EventCategoryEntity? eventCategory;

  const UnifiedCategoryEntity({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.type,
    this.spaceCategory,
    this.eventCategory,
  });

  // 매장 카테고리로부터 생성
  factory UnifiedCategoryEntity.fromSpaceCategory(
    SpaceCategory category,
    String name,
    String iconPath,
  ) {
    return UnifiedCategoryEntity(
      id: category.toString(),
      name: name,
      iconUrl: iconPath,
      type: CategoryType.space,
      spaceCategory: category,
    );
  }

  // 이벤트 카테고리로부터 생성
  factory UnifiedCategoryEntity.fromEventCategory(EventCategoryEntity category) {
    return UnifiedCategoryEntity(
      id: 'event_${category.id}',
      name: category.name,
      iconUrl: category.iconUrl,
      type: CategoryType.event,
      eventCategory: category,
    );
  }

  @override
  List<Object?> get props => [id, name, iconUrl, type, spaceCategory, eventCategory];
}
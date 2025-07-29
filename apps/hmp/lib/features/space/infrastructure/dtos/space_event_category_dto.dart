import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/space_event_category_entity.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/event_category_dto.dart';

part 'space_event_category_dto.g.dart';

@JsonSerializable()
class SpaceEventCategoryDto extends Equatable {
  @JsonKey(name: 'eventCategory')
  final EventCategoryDto? eventCategory;

  const SpaceEventCategoryDto({
    this.eventCategory,
  });

  factory SpaceEventCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$SpaceEventCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceEventCategoryDtoToJson(this);

  @override
  List<Object?> get props => [eventCategory];

  SpaceEventCategoryEntity toEntity() {
    return SpaceEventCategoryEntity(
      eventCategory: eventCategory?.toEntity() ?? const EventCategoryEntity.empty(),
    );
  }
}
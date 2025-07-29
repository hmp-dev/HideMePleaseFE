import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/event_category_entity.dart';

part 'event_category_dto.g.dart';

@JsonSerializable()
class EventCategoryDto extends Equatable {
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'nameEn')
  final String? nameEn;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'descriptionEn')
  final String? descriptionEn;
  @JsonKey(name: 'displayOrder')
  final int? displayOrder;
  @JsonKey(name: 'isActive')
  final bool? isActive;
  @JsonKey(name: 'colorCode')
  final String? colorCode;
  @JsonKey(name: 'iconUrl')
  final String? iconUrl;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const EventCategoryDto({
    this.id,
    this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    this.displayOrder,
    this.isActive,
    this.colorCode,
    this.iconUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory EventCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$EventCategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventCategoryDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        nameEn,
        description,
        descriptionEn,
        displayOrder,
        isActive,
        colorCode,
        iconUrl,
        createdAt,
        updatedAt,
      ];

  EventCategoryEntity toEntity() {
    return EventCategoryEntity(
      id: id ?? '',
      name: name ?? '',
      nameEn: nameEn,
      description: description,
      descriptionEn: descriptionEn,
      displayOrder: displayOrder ?? 0,
      isActive: isActive ?? false,
      colorCode: colorCode,
      iconUrl: iconUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
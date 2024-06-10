import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/settings/domain/entities/announcement_entity.dart';

part 'announcement_dto.g.dart';

@JsonSerializable()
class AnnouncementDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @JsonKey(name: "title")
  final String? title;
  @JsonKey(name: "description")
  final String? description;

  const AnnouncementDto({
    this.id,
    this.createdAt,
    this.title,
    this.description,
  });

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        createdAt,
        title,
        description,
      ];

  AnnouncementEntity toEntity() => AnnouncementEntity(
        id: id ?? "",
        createdAt: createdAt ?? "",
        title: title ?? "",
        description: description ?? "",
      );
}

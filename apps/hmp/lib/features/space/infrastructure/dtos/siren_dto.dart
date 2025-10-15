import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_author_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_space_dto.dart';

part 'siren_dto.g.dart';

@JsonSerializable()
class SirenDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "message")
  final String? message;

  @JsonKey(name: "createdAt")
  final String? createdAt;

  @JsonKey(name: "expiresAt")
  final String? expiresAt;

  @JsonKey(name: "pointsSpent")
  final int? pointsSpent;

  @JsonKey(name: "remainingDays")
  final int? remainingDays;

  @JsonKey(name: "space")
  final SirenSpaceDto? space;

  @JsonKey(name: "author")
  final SirenAuthorDto? author;

  @JsonKey(name: "distance")
  final double? distance;

  const SirenDto({
    this.id,
    this.message,
    this.createdAt,
    this.expiresAt,
    this.pointsSpent,
    this.remainingDays,
    this.space,
    this.author,
    this.distance,
  });

  factory SirenDto.fromJson(Map<String, dynamic> json) =>
      _$SirenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenDtoToJson(this);

  SirenEntity toEntity() {
    // API 응답에서 받은 distance 값 로그 출력
    if (distance == null || distance == 0.0) {
      print('⚠️ [SirenDto] Distance is ${distance ?? "null"} for siren: $id, space: ${space?.name}');
    }

    return SirenEntity(
      id: id ?? '',
      message: message ?? '',
      createdAt: createdAt ?? '',
      expiresAt: expiresAt ?? '',
      pointsSpent: pointsSpent ?? 0,
      remainingDays: remainingDays ?? 0,
      space: space?.toEntity(),
      author: author?.toEntity(),
      distance: distance ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        message,
        createdAt,
        expiresAt,
        pointsSpent,
        remainingDays,
        space,
        author,
        distance,
      ];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/recommendation_space_entity.dart';

part 'recommendation_space_dto.g.dart';

@JsonSerializable()
class RecommendationSpaceDto extends Equatable {
  @JsonKey(name: "spaceId")
  final String? spaceId;
  @JsonKey(name: "spaceName")
  final String? spaceName;
  @JsonKey(name: "users")
  final int? users;

  const RecommendationSpaceDto({
    this.spaceId,
    this.spaceName,
    this.users,
  });

  factory RecommendationSpaceDto.fromJson(Map<String, dynamic> json) =>
      _$RecommendationSpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationSpaceDtoToJson(this);

  @override
  List<Object?> get props => [spaceId, spaceName, users];

  RecommendationSpaceEntity toEntity() => RecommendationSpaceEntity(
        spaceId: spaceId ?? "",
        spaceName: spaceName ?? "",
        users: users ?? 0,
      );
}

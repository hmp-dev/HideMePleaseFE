import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/spaces_response_entity.dart';

import 'package:mobile/features/space/infrastructure/dtos/near_by_space_dto.dart';

part 'spaces_response_dto.g.dart';

@JsonSerializable()
class SpacesResponseDto extends Equatable {
  @JsonKey(name: "spaces")
  final List<NearBySpaceDto>? spaces;
  @JsonKey(name: "ambiguous")
  final bool? ambiguous;

  const SpacesResponseDto({
    this.spaces,
    this.ambiguous,
  });

  factory SpacesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SpacesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpacesResponseDtoToJson(this);

  @override
  List<Object?> get props => [spaces, ambiguous];

  SpacesResponseEntity toEntity() => SpacesResponseEntity(
      spaces: spaces?.map((e) => e.toEntity()).toList() ?? [],
      ambiguous: ambiguous ?? false);
}

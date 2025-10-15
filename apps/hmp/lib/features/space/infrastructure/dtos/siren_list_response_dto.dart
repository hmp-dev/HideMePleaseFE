import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_list_response_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/siren_pagination_dto.dart';

part 'siren_list_response_dto.g.dart';

@JsonSerializable()
class SirenListResponseDto extends Equatable {
  @JsonKey(name: "sirens")
  final List<SirenDto>? sirens;

  @JsonKey(name: "pagination")
  final SirenPaginationDto? pagination;

  const SirenListResponseDto({
    this.sirens,
    this.pagination,
  });

  factory SirenListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SirenListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenListResponseDtoToJson(this);

  SirenListResponseEntity toEntity() {
    return SirenListResponseEntity(
      sirens: sirens?.map((e) => e.toEntity()).toList() ?? [],
      pagination: pagination?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [sirens, pagination];
}

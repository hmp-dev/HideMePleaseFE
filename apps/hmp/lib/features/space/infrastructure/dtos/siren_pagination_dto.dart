import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_pagination_entity.dart';

part 'siren_pagination_dto.g.dart';

@JsonSerializable()
class SirenPaginationDto extends Equatable {
  @JsonKey(name: "page")
  final int? page;

  @JsonKey(name: "limit")
  final int? limit;

  @JsonKey(name: "total")
  final int? total;

  @JsonKey(name: "totalPages")
  final int? totalPages;

  const SirenPaginationDto({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory SirenPaginationDto.fromJson(Map<String, dynamic> json) =>
      _$SirenPaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenPaginationDtoToJson(this);

  SirenPaginationEntity toEntity() {
    return SirenPaginationEntity(
      page: page ?? 1,
      limit: limit ?? 20,
      total: total ?? 0,
      totalPages: totalPages ?? 0,
    );
  }

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/pagination_entity.dart';

part 'pagination_dto.g.dart';

@JsonSerializable()
class PaginationDto extends Equatable {
  @JsonKey(name: "page")
  final int? page;

  @JsonKey(name: "limit")
  final int? limit;

  @JsonKey(name: "total")
  final int? total;

  @JsonKey(name: "totalPages")
  final int? totalPages;

  const PaginationDto({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);

  PaginationEntity toEntity() {
    return PaginationEntity(
      page: page ?? 1,
      limit: limit ?? 20,
      total: total ?? 0,
      totalPages: totalPages ?? 0,
    );
  }

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}

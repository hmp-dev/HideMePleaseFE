import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_stats_entity.dart';

part 'siren_stats_dto.g.dart';

@JsonSerializable()
class SirenStatsDto extends Equatable {
  @JsonKey(name: "activeSirensCount")
  final int? activeSirensCount;

  @JsonKey(name: "totalSirensCount")
  final int? totalSirensCount;

  const SirenStatsDto({
    this.activeSirensCount,
    this.totalSirensCount,
  });

  factory SirenStatsDto.fromJson(Map<String, dynamic> json) =>
      _$SirenStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenStatsDtoToJson(this);

  SirenStatsEntity toEntity() {
    return SirenStatsEntity(
      activeSirensCount: activeSirensCount ?? 0,
      totalSirensCount: totalSirensCount ?? 0,
    );
  }

  @override
  List<Object?> get props => [activeSirensCount, totalSirensCount];
}

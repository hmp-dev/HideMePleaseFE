import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';

import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';

part 'welcome_nft_dto.g.dart';

@JsonSerializable()
class WelcomeNftDto extends Equatable {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "totalCount")
  final int? totalCount;
  @JsonKey(name: "usedCount")
  final int? usedCount;
  final String? name;
  final String? tokenAddress;

  const WelcomeNftDto({
    this.id,
    this.image,
    this.totalCount,
    this.usedCount,
    this.name,
    this.tokenAddress,
  });

  factory WelcomeNftDto.fromJson(Map<String, dynamic> json) =>
      _$WelcomeNftDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WelcomeNftDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        image,
        totalCount,
        usedCount,
        name,
        tokenAddress,
      ];

  WelcomeNftEntity toEntity() => WelcomeNftEntity(
        image: image ?? '',
        totalCount: totalCount ?? 0,
        usedCount: usedCount ?? 0,
        tokenAddress: tokenAddress ?? '',
      );
}

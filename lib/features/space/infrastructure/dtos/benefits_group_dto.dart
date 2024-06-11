import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/nft/infrastructure/dtos/benefit_dto.dart';
import 'package:mobile/features/space/domain/entities/benefits_group_entity.dart';

part 'benefits_group_dto.g.dart';

@JsonSerializable()
class BenefitsGroupDto extends Equatable {
  @JsonKey(name: "benefits")
  final List<BenefitDto>? benefits;
  @JsonKey(name: "next")
  final String? next;

  const BenefitsGroupDto({
    this.benefits,
    this.next,
  });

  factory BenefitsGroupDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitsGroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BenefitsGroupDtoToJson(this);

  @override
  List<Object?> get props => [benefits, next];

  BenefitsGroupEntity toEntity() => BenefitsGroupEntity(
        benefits: benefits?.map((e) => e.toEntity()).toList() ?? [],
        next: next ?? '',
      );
}



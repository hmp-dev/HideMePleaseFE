import 'package:equatable/equatable.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

class BenefitsGroupEntity extends Equatable {
  final List<BenefitEntity> benefits;
  final int benefitCount;
  final String next;

  const BenefitsGroupEntity({
    required this.benefits,
    required this.benefitCount,
    required this.next,
  });

  @override
  List<Object?> get props => [
        benefits,
        benefitCount,
        next,
      ];

  BenefitsGroupEntity.empty()
      : benefits = [],
        benefitCount = 0,
        next = '';

  BenefitsGroupEntity copyWith({
    List<BenefitEntity>? benefits,
    int? benefitCount,
    String? next,
  }) {
    return BenefitsGroupEntity(
      benefits: benefits ?? this.benefits,
      benefitCount: benefitCount ?? this.benefitCount,
      next: next ?? this.next,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

class BenefitsGroupEntity extends Equatable {
  final List<BenefitEntity> benefits;
  final String next;

  const BenefitsGroupEntity({
    required this.benefits,
    required this.next,
  });

  @override
  List<Object?> get props => [
        benefits,
        next,
      ];

  BenefitsGroupEntity.empty()
      : benefits = [],
        next = '';

  BenefitsGroupEntity copyWith({
    List<BenefitEntity>? benefits,
    String? next,
  }) {
    return BenefitsGroupEntity(
      benefits: benefits ?? this.benefits,
      next: next ?? this.next,
    );
  }
}

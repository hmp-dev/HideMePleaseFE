import 'package:equatable/equatable.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

/// Represents a group of benefits.
///
/// This class holds data about a group of benefits, including the list of
/// benefits, the number of benefits, and the next link.
class BenefitsGroupEntity extends Equatable {
  /// The list of benefits in the group.
  final List<BenefitEntity> benefits;

  /// The number of benefits in the group.
  final int benefitCount;

  /// The next link for fetching more benefits.
  final String next;

  /// Creates a [BenefitsGroupEntity] instance with the given [benefits],
  /// [benefitCount], and [next].
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

  /// Creates an empty [BenefitsGroupEntity] instance.
  ///
  /// The [benefits] list is empty, [benefitCount] is 0, and [next] is an empty
  /// string.
  BenefitsGroupEntity.empty()
      : benefits = [],
        benefitCount = 0,
        next = '';

  /// Creates a copy of this [BenefitsGroupEntity] instance with the given
  /// [benefits], [benefitCount], and [next].
  ///
  /// If any of the parameters are null, the corresponding property of this
  /// instance is used instead.
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

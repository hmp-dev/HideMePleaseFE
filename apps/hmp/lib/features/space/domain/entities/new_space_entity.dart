import 'package:equatable/equatable.dart';

class NewSpaceEntity extends Equatable {
  final String id;
  final String name;
  final String image;
  final String mainBenefitDescription;
  final int remainingBenefitCount;
  final int hidingCount;

  const NewSpaceEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.mainBenefitDescription,
    required this.remainingBenefitCount,
    required this.hidingCount,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      mainBenefitDescription,
      remainingBenefitCount,
      hidingCount,
    ];
  }

  NewSpaceEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? mainBenefitDescription,
    int? remainingBenefitCount,
    int? hidingCount,
  }) {
    return NewSpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      mainBenefitDescription:
          mainBenefitDescription ?? this.mainBenefitDescription,
      remainingBenefitCount:
          remainingBenefitCount ?? this.remainingBenefitCount,
      hidingCount: hidingCount ?? this.hidingCount,
    );
  }

  const NewSpaceEntity.empty()
      : id = '',
        name = '',
        image = '',
        mainBenefitDescription = '',
        remainingBenefitCount = 0,
        hidingCount = 0;
}

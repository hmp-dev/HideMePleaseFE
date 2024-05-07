import 'package:equatable/equatable.dart';

class NftBenefitEntity extends Equatable {
  // remove all json ket and make required
  final String id;
  final String description;
  final bool singleUse;
  final String spaceId;
  final String spaceName;
  final String? spaceImage;
  final bool? used;

  const NftBenefitEntity({
    required this.id,
    required this.description,
    required this.singleUse,
    required this.spaceId,
    required this.spaceName,
    required this.spaceImage,
    required this.used,
  });

  @override
  List<Object?> get props {
    return [
      id,
      description,
      singleUse,
      spaceId,
      spaceName,
      spaceImage,
      used,
    ];
  }

  NftBenefitEntity copyWith({
    String? id,
    String? description,
    bool? singleUse,
    String? spaceId,
    String? spaceName,
    String? spaceImage,
    bool? used,
  }) {
    return NftBenefitEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      singleUse: singleUse ?? this.singleUse,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceImage: spaceImage ?? this.spaceImage,
      used: used ?? this.used,
    );
  }

  const NftBenefitEntity.empty()
      : id = '',
        description = '',
        singleUse = false,
        spaceId = '',
        spaceName = '',
        spaceImage = '',
        used = false;
}

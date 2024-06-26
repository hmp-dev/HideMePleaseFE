import 'package:equatable/equatable.dart';

class BenefitEntity extends Equatable {
  // remove all json ket and make required
  final String id;
  final String description;
  final bool singleUse;
  final String spaceId;
  final String spaceName;
  final String spaceImage;
  final bool used;
  final String state;
  final String tokenAddress;
  final String nftCollectionName;
  final String termsUrl;

  const BenefitEntity({
    required this.id,
    required this.description,
    required this.singleUse,
    required this.spaceId,
    required this.spaceName,
    required this.spaceImage,
    required this.used,
    required this.state,
    required this.tokenAddress,
    required this.nftCollectionName,
    required this.termsUrl,
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
      state,
      tokenAddress,
      nftCollectionName,
      termsUrl
    ];
  }

  BenefitEntity copyWith({
    String? id,
    String? description,
    bool? singleUse,
    String? spaceId,
    String? spaceName,
    String? spaceImage,
    bool? used,
    String? state,
    String? tokenAddress,
    String? nftCollectionName,
    String? termsUrl,
  }) {
    return BenefitEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      singleUse: singleUse ?? this.singleUse,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceImage: spaceImage ?? this.spaceImage,
      used: used ?? this.used,
      state: state ?? this.state,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      nftCollectionName: nftCollectionName ?? this.nftCollectionName,
      termsUrl: termsUrl ?? this.termsUrl,
    );
  }

  const BenefitEntity.empty()
      : id = '',
        description = '',
        singleUse = false,
        spaceId = '',
        spaceName = '',
        spaceImage = '',
        used = false,
        state = '',
        tokenAddress = '',
        nftCollectionName = '',
        termsUrl = '';
}

import 'package:equatable/equatable.dart';

class BenefitEntity extends Equatable {
  // remove all json ket and make required
  final String id;
  final String description;
  final String descriptionEn;
  final bool singleUse;
  final String spaceId;
  final String spaceName;
  final String spaceNameEn;
  final String spaceImage;
  final bool used;
  final String state;
  final String tokenAddress;
  final String nftCollectionName;
  final String termsUrl;
  final String nftCollectionImage;
  final String nftCollectionVideo;
  final String nftCollectionChain;

  const BenefitEntity({
    required this.id,
    required this.description,
    this.descriptionEn = '',
    required this.singleUse,
    required this.spaceId,
    required this.spaceName,
    this.spaceNameEn = '',
    required this.spaceImage,
    required this.used,
    required this.state,
    required this.tokenAddress,
    required this.nftCollectionName,
    required this.termsUrl,
    required this.nftCollectionImage,
    required this.nftCollectionVideo,
    required this.nftCollectionChain,
  });

  @override
  List<Object?> get props {
    return [
      id,
      description,
      descriptionEn,
      singleUse,
      spaceId,
      spaceName,
      spaceNameEn,
      spaceImage,
      used,
      state,
      tokenAddress,
      nftCollectionName,
      termsUrl,
      nftCollectionImage,
      nftCollectionVideo,
      nftCollectionChain,
    ];
  }

  BenefitEntity copyWith({
    String? id,
    String? description,
    String? descriptionEn,
    bool? singleUse,
    String? spaceId,
    String? spaceName,
    String? spaceNameEn,
    String? spaceImage,
    bool? used,
    String? state,
    String? tokenAddress,
    String? nftCollectionName,
    String? termsUrl,
    String? nftCollectionImage,
    String? nftCollectionVideo,
    String? nftCollectionChain,
  }) {
    return BenefitEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      singleUse: singleUse ?? this.singleUse,
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      spaceNameEn: spaceNameEn ?? this.spaceNameEn,
      spaceImage: spaceImage ?? this.spaceImage,
      used: used ?? this.used,
      state: state ?? this.state,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      nftCollectionName: nftCollectionName ?? this.nftCollectionName,
      termsUrl: termsUrl ?? this.termsUrl,
      nftCollectionImage: nftCollectionImage ?? this.nftCollectionImage,
      nftCollectionVideo: nftCollectionVideo ?? this.nftCollectionVideo,
      nftCollectionChain: nftCollectionChain ?? this.nftCollectionChain,
    );
  }

  const BenefitEntity.empty()
      : id = '',
        description = '',
        descriptionEn = '',
        singleUse = false,
        spaceId = '',
        spaceName = '',
        spaceNameEn = '',
        spaceImage = '',
        used = false,
        state = '',
        tokenAddress = '',
        nftCollectionName = '',
        termsUrl = '',
        nftCollectionImage = '',
        nftCollectionVideo = '',
        nftCollectionChain = '';
}

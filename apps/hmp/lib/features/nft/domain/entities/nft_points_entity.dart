import 'package:equatable/equatable.dart';

class NftPointsEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String videoUrl;
  final String tokenAddress;
  final int totalPoints;

  const NftPointsEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
    required this.tokenAddress,
    required this.totalPoints,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      imageUrl,
      videoUrl,
      tokenAddress,
      totalPoints,
    ];
  }

  NftPointsEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? videoUrl,
    String? tokenAddress,
    int? totalPoints,
  }) {
    return NftPointsEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  const NftPointsEntity.empty()
      : id = '',
        name = '',
        imageUrl = '',
        videoUrl = '',
        tokenAddress = '',
        totalPoints = 0;
}

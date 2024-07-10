import 'package:equatable/equatable.dart';

class NftPointsEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String tokenAddress;
  final int totalPoints;

  const NftPointsEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.tokenAddress,
    required this.totalPoints,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      imageUrl,
      tokenAddress,
      totalPoints,
    ];
  }

  NftPointsEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? tokenAddress,
    int? totalPoints,
  }) {
    return NftPointsEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  const NftPointsEntity.empty()
      : id = '',
        name = '',
        imageUrl = '',
        tokenAddress = '',
        totalPoints = 0;
}

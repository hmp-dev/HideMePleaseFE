import 'package:equatable/equatable.dart';

class SelectedNFTEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String videoUrl;
  final int order;
  final String tokenAddress;
  final String symbol;
  final String chain;
  final int totalPoints;
  final int communityRank;
  final int totalMembers;
  final int pointFluctuation;

  const SelectedNFTEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
    required this.order,
    required this.tokenAddress,
    required this.symbol,
    required this.chain,
    required this.totalPoints,
    required this.communityRank,
    required this.totalMembers,
    required this.pointFluctuation,
  });

  const SelectedNFTEntity.empty()
      : id = '',
        order = 0,
        name = '',
        tokenAddress = '',
        symbol = '',
        chain = '',
        imageUrl = '',
        videoUrl = '',
        totalPoints = 0,
        communityRank = 0,
        totalMembers = 0,
        pointFluctuation = 0;

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        symbol,
        chain,
        imageUrl,
        videoUrl,
        totalPoints,
        communityRank,
        totalMembers,
        pointFluctuation,
        tokenAddress
      ];

  SelectedNFTEntity copyWith({
    String? id,
    int? order,
    String? name,
    String? symbol,
    String? chain,
    String? imageUrl,
    String? videoUrl,
    String? tokenAddress,
    int? totalPoints,
    int? communityRank,
    int? totalMembers,
    int? pointFluctuation,
  }) {
    return SelectedNFTEntity(
      id: id ?? this.id,
      order: order ?? this.order,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      chain: chain ?? this.chain,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      totalPoints: totalPoints ?? this.totalPoints,
      communityRank: communityRank ?? this.communityRank,
      totalMembers: totalMembers ?? this.totalMembers,
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
    );
  }

  const SelectedNFTEntity.emptyForHome1st()
      : id = '',
        order = 0,
        name = '',
        symbol = '',
        chain = 'KLAYTN',
        imageUrl = '',
        videoUrl = '',
        tokenAddress = '',
        totalPoints = 0,
        communityRank = 0,
        totalMembers = 0,
        pointFluctuation = 0;

  @override
  String toString() {
    return 'SelectedNFTEntity(id: $id, name: $name, imageUrl: $imageUrl, videoUrl: $videoUrl, order: $order, tokenAddress: $tokenAddress, symbol: $symbol, chain: $chain, totalPoints: $totalPoints, communityRank: $communityRank, totalMembers: $totalMembers, pointFluctuation: $pointFluctuation)';
  }
}

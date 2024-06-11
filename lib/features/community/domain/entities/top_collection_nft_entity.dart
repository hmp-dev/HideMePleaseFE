import 'package:equatable/equatable.dart';

class TopCollectionNftEntity extends Equatable {
  final int pointFluctuation;
  final int totalPoints;
  final String tokenAddress;
  final String collectionLogo;
  final String name;
  final String chain;
  final bool ownedCollection;
  final int communityRank;

  const TopCollectionNftEntity({
    required this.pointFluctuation,
    required this.totalPoints,
    required this.tokenAddress,
    required this.collectionLogo,
    required this.name,
    required this.chain,
    required this.ownedCollection,
    required this.communityRank,
  });

  @override
  List<Object?> get props {
    return [
      pointFluctuation,
      totalPoints,
      tokenAddress,
      collectionLogo,
      name,
      chain,
      ownedCollection,
      communityRank,
    ];
  }

  /// Creates a singleton-like empty instance of `TopUsedNftEntity`.
  /// This constant constructor ensures all instances of the empty object share the same memory,
  /// improving performance and reducing memory usage.
  const TopCollectionNftEntity.empty()
      : pointFluctuation = 0,
        totalPoints = 0,
        tokenAddress = '',
        collectionLogo = '',
        name = '',
        chain = '',
        ownedCollection = false,
        communityRank = 0;

  //create copy with new values
  TopCollectionNftEntity copyWith({
    int? pointFluctuation,
    int? totalPoints,
    String? tokenAddress,
    String? collectionLogo,
    String? name,
    String? chain,
    bool? ownedCollection,
    int? communityRank,
  }) {
    return TopCollectionNftEntity(
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
      totalPoints: totalPoints ?? this.totalPoints,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      name: name ?? this.name,
      chain: chain ?? this.chain,
      ownedCollection: ownedCollection ?? this.ownedCollection,
      communityRank: communityRank ?? this.communityRank,
    );
  }
}

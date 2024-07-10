import 'package:equatable/equatable.dart';

class TopUsedNftEntity extends Equatable {
  final int pointFluctuation;
  final int totalPoints;
  final String tokenAddress;
  final int totalMembers;
  final int communityRank;
  final String collectionLogo;
  final String name;
  final String chain;
  final bool ownedCollection;

  const TopUsedNftEntity({
    required this.pointFluctuation,
    required this.totalPoints,
    required this.tokenAddress,
    required this.totalMembers,
    required this.communityRank,
    required this.collectionLogo,
    required this.name,
    required this.chain,
    required this.ownedCollection,
  });

  @override
  List<Object?> get props {
    return [
      pointFluctuation,
      totalPoints,
      tokenAddress,
      totalMembers,
      communityRank,
      collectionLogo,
      name,
      chain,
      ownedCollection
    ];
  }

  /// Creates a singleton-like empty instance of `TopUsedNftEntity`.
  /// This constant constructor ensures all instances of the empty object share the same memory,
  /// improving performance and reducing memory usage.
  const TopUsedNftEntity.empty()
      : pointFluctuation = 0,
        totalPoints = 0,
        tokenAddress = '',
        totalMembers = 0,
        communityRank = 0,
        collectionLogo = '',
        name = '',
        chain = '',
        ownedCollection = false;

  //create copy with new values
  TopUsedNftEntity copyWith({
    int? pointFluctuation,
    int? totalPoints,
    String? tokenAddress,
    int? totalMembers,
    int? communityRank,
    String? collectionLogo,
    String? name,
    String? chain,
    bool? ownedCollection,
  }) {
    return TopUsedNftEntity(
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
      totalPoints: totalPoints ?? this.totalPoints,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      totalMembers: totalMembers ?? this.totalMembers,
      communityRank: communityRank ?? this.communityRank,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      name: name ?? this.name,
      chain: chain ?? this.chain,
      ownedCollection: ownedCollection ?? this.ownedCollection,
    );
  }
}

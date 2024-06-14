import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

final koreanNumFormat = NumberFormat("###,###,### P", "en_US");

class TopCollectionNftEntity extends Equatable {
  final int index;
  final int pointFluctuation;
  final int totalPoints;
  final int totalMembers;
  final String tokenAddress;
  final String collectionLogo;
  final String name;
  final String chain;
  final bool ownedCollection;
  final int communityRank;

  const TopCollectionNftEntity({
    required this.index,
    required this.pointFluctuation,
    required this.totalPoints,
    required this.totalMembers,
    required this.tokenAddress,
    required this.collectionLogo,
    required this.name,
    required this.chain,
    required this.ownedCollection,
    required this.communityRank,
  });

  String get pointsFormatted => koreanNumFormat.format(totalPoints);

  String get chainLogo => "assets/chain-logos/${chain.toLowerCase()}_chain.svg";

  @override
  List<Object?> get props {
    return [
      index,
      pointFluctuation,
      totalPoints,
      totalMembers,
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
      : index = 0,
        pointFluctuation = 0,
        totalPoints = 0,
        totalMembers = 0,
        tokenAddress = '',
        collectionLogo = '',
        name = '',
        chain = '',
        ownedCollection = false,
        communityRank = 0;

  //create copy with new values
  TopCollectionNftEntity copyWith({
    int? index,
    int? pointFluctuation,
    int? totalPoints,
    int? totalMembers,
    String? tokenAddress,
    String? collectionLogo,
    String? name,
    String? chain,
    bool? ownedCollection,
    int? communityRank,
  }) {
    return TopCollectionNftEntity(
      index: index ?? this.index,
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
      totalPoints: totalPoints ?? this.totalPoints,
      totalMembers: totalMembers ?? this.totalMembers,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      name: name ?? this.name,
      chain: chain ?? this.chain,
      ownedCollection: ownedCollection ?? this.ownedCollection,
      communityRank: communityRank ?? this.communityRank,
    );
  }
}

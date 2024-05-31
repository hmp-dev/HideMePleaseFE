import 'package:equatable/equatable.dart';

class TopUsedNftEntity extends Equatable {
  final int pointFluctuation;
  final int totalPoints;
  final String tokenAddress;
  final String collectionLogo;
  final String name;
  final String chain;

  const TopUsedNftEntity({
    required this.pointFluctuation,
    required this.totalPoints,
    required this.tokenAddress,
    required this.collectionLogo,
    required this.name,
    required this.chain,
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
    ];
  }

  /// Creates a singleton-like empty instance of `TopUsedNftEntity`.
  /// This constant constructor ensures all instances of the empty object share the same memory,
  /// improving performance and reducing memory usage.
  const TopUsedNftEntity.empty()
      : pointFluctuation = 0,
        totalPoints = 0,
        tokenAddress = '',
        collectionLogo = '',
        name = '',
        chain = '';

  //create copy with new values
  TopUsedNftEntity copyWith({
    int? pointFluctuation,
    int? totalPoints,
    String? tokenAddress,
    String? collectionLogo,
    String? name,
    String? chain,
  }) {
    return TopUsedNftEntity(
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
      totalPoints: totalPoints ?? this.totalPoints,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      name: name ?? this.name,
      chain: chain ?? this.chain,
    );
  }
}

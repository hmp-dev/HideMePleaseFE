// ignore_for_file: constant_identifier_names

enum ChainType {
  ALL,
  ETHEREUM,
  SOLANA,
  POLYGON,
  KLAYTN,
  AVALANCHE;

  /// Converts the given [chain] string to a [ChainType] enum case.
  ///
  /// The [chain] string is converted to uppercase before comparison.
  /// If the [chain] string is null or does not match any of the enum cases,
  /// [ChainType.ALL] is returned.
  static ChainType fromString(String? chain) {
    // Convert the chain string to uppercase for case insensitive comparison.
    chain = chain?.toUpperCase();

    // Match the chain string to the corresponding enum case.
    switch (chain) {
      case 'ETHEREUM':
        return ChainType.ETHEREUM; // Returns ChainType.ETHEREUM enum case.
      case 'SOLANA':
        return ChainType.SOLANA; // Returns ChainType.SOLANA enum case.
      case 'POLYGON':
        return ChainType.POLYGON; // Returns ChainType.POLYGON enum case.
      case 'KLAYTN':
        return ChainType.KLAYTN; // Returns ChainType.KLAYTN enum case.
      case 'AVALANCHE':
        return ChainType.AVALANCHE; // Returns ChainType.AVALANCHE enum case.
      default:
        return ChainType.ALL; // Returns ChainType.ALL enum case.
    }
  }

  /// Returns the logo path for the chain based on the given [ChainType].
  String get chainLogo {
    switch (this) {
      case ChainType.ETHEREUM:
        return 'assets/chain-logos/ethereum_chain.svg';
      case ChainType.SOLANA:
        return 'assets/chain-logos/solana_chain.svg';
      case ChainType.POLYGON:
        return 'assets/chain-logos/polygon_chain.svg';
      case ChainType.KLAYTN:
        return 'assets/chain-logos/klaytn_chain.png';
      case ChainType.AVALANCHE:
        return 'assets/chain-logos/avalanche_chain.svg';
      default:
        return 'assets/chain-logos/ethereum_chain.svg';
    }
  }

  /// Returns the label associated with the [ChainType].
  ///
  /// This getter provides a human-readable string representation
  /// of the [ChainType] enum value.
  ///
  /// - `ChainType.ETHEREUM`: Returns 'Ethereum'.
  /// - `ChainType.SOLANA`: Returns 'Solana'.
  /// - `ChainType.POLYGON`: Returns 'Polygon'.
  /// - `ChainType.KLAYTN`: Returns 'Klaytn'.
  /// - Default: Returns 'All'.
  String get label {
    switch (this) {
      case ChainType.ETHEREUM:
        return 'Ethereum';
      case ChainType.SOLANA:
        return 'Solana';
      case ChainType.POLYGON:
        return 'Polygon';
      case ChainType.KLAYTN:
        return 'Klaytn';
      default:
        return 'All';
    }
  }
}

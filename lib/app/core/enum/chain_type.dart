// ignore_for_file: constant_identifier_names

enum ChainType {
  ALL,
  ETHEREUM,
  SOLANA,
  POLYGON,
  KLAYTN;

  static ChainType fromString(String? chain) {
    chain = chain?.toUpperCase();
    switch (chain) {
      case 'ETHEREUM':
        return ChainType.ETHEREUM;
      case 'SOLANA':
        return ChainType.SOLANA;
      case 'POLYGON':
        return ChainType.POLYGON;
      case 'KLAYTN':
        return ChainType.KLAYTN;
      default:
        return ChainType.ALL;
    }
  }

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
      default:
        return 'assets/chain-logos/ethereum_chain.svg';
    }
  }

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

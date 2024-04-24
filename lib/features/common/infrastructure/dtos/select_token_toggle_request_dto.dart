class SelectTokenToggleRequestDto {
  String tokenId;
  String tokenAddress;
  String chain;
  String walletAddress;
  bool selected;
  int order;

  SelectTokenToggleRequestDto({
    required this.tokenId,
    required this.tokenAddress,
    required this.chain,
    required this.walletAddress,
    required this.selected,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      "tokenId": tokenId,
      "tokenAddress": tokenAddress,
      "chain": chain,
      "walletAddress": walletAddress,
      "selected": selected,
      "order": order,
    };
  }
}

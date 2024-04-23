class SaveWalletRequestDto {
  String publicAddress;
  String provider;

  SaveWalletRequestDto({
    required this.publicAddress,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'publicAddress': publicAddress,
      'provider': provider,
    };
  }
}

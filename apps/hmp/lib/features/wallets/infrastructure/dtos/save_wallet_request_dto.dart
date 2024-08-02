/// A data transfer object (DTO) that represents the request payload for saving a wallet.
///
/// This class holds the [publicAddress] and [provider] properties, which are essential
/// for saving a wallet.
class SaveWalletRequestDto {
  /// The public address of the wallet.
  ///
  /// It is a required property.
  final String publicAddress;

  /// The provider of the wallet.
  ///
  /// It is a required property.
  final String provider;

  /// Creates a [SaveWalletRequestDto] instance with the provided [publicAddress] and [provider].
  ///
  /// The [publicAddress] and [provider] parameters must not be null.
  SaveWalletRequestDto({
    required this.publicAddress,
    required this.provider,
  });

  /// Converts the object into a JSON representation.
  ///
  /// Returns a [Map] containing the [publicAddress] and [provider] properties.
  Map<String, dynamic> toJson() {
    return {
      'publicAddress': publicAddress,
      'provider': provider,
    };
  }
}

import 'package:equatable/equatable.dart';

/// Represents a wallet that is connected to a user.
///
/// This class holds the information about a connected wallet, including its
/// ID, deletion status, user ID, public address, and provider.
class ConnectedWalletEntity extends Equatable {
  /// The unique identifier of the wallet.
  final String id;

  /// Indicates whether the wallet has been deleted.
  final bool deleted;

  /// The ID of the user who owns the wallet.
  final String userId;

  /// The public address of the wallet.
  final String publicAddress;

  /// The provider of the wallet, such as Solana, Ethereum, etc.
  final String provider;

  /// Initializes a [ConnectedWalletEntity] with the given parameters.
  ///
  /// All the parameters are required and cannot be null.
  const ConnectedWalletEntity({
    required this.id,
    required this.deleted,
    required this.userId,
    required this.publicAddress,
    required this.provider,
  });

  /// An empty [ConnectedWalletEntity] with all the fields set to empty strings.
  static const ConnectedWalletEntity empty = ConnectedWalletEntity(
    id: '',
    deleted: false,
    userId: '',
    publicAddress: '',
    provider: '',
  );

  @override
  List<Object?> get props {
    // Returns a list of the object's properties.
    return [
      id,
      deleted,
      userId,
      publicAddress,
      provider,
    ];
  }
}

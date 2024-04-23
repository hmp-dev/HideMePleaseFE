import 'package:equatable/equatable.dart';

class ConnectedWalletEntity extends Equatable {
  final String id;
  final bool deleted;
  final String userId;
  final String publicAddress;
  final String provider;

  const ConnectedWalletEntity({
    required this.id,
    required this.deleted,
    required this.userId,
    required this.publicAddress,
    required this.provider,
  });

  static const ConnectedWalletEntity empty = ConnectedWalletEntity(
    id: '',
    deleted: false,
    userId: '',
    publicAddress: '',
    provider: '',
  );

  @override
  List<Object?> get props {
    return [
      id,
      deleted,
      userId,
      publicAddress,
      provider,
    ];
  }
}

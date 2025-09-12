import 'package:equatable/equatable.dart';

class MintNftRequestEntity extends Equatable {
  final String walletAddress;
  final String imageUrl;
  final String metadataUrl;

  const MintNftRequestEntity({
    required this.walletAddress,
    required this.imageUrl,
    required this.metadataUrl,
  });

  @override
  List<Object?> get props => [walletAddress, imageUrl, metadataUrl];
}
import 'package:equatable/equatable.dart';

import 'package:mobile/app/core/cubit/cubit.dart';

class UserSelectedNftEntity extends Equatable {
  final String nftImageUrl;
  final String nftId;

  const UserSelectedNftEntity({
    required this.nftImageUrl,
    required this.nftId,
  });

  @override
  List<Object?> get props => [
        nftImageUrl,
        nftId,
      ];

  const UserSelectedNftEntity.empty()
      : nftImageUrl = '',
        nftId = '';

  UserSelectedNftEntity copyWith({
    String? nftImageUrl,
    String? nftId,
  }) {
    return UserSelectedNftEntity(
      nftImageUrl: nftImageUrl ?? this.nftImageUrl,
      nftId: nftId ?? this.nftId,
    );
  }
}

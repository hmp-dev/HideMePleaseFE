import 'package:equatable/equatable.dart';

class NextCollectionsEntity extends Equatable {
  final String type;
  final String cursor;
  final String nextWalletAddress;

  const NextCollectionsEntity({
    required this.type,
    required this.cursor,
    required this.nextWalletAddress,
  });

  @override
  List<Object> get props => [type, cursor, nextWalletAddress];

  NextCollectionsEntity copyWith({
    String? type,
    String? cursor,
    String? nextWalletAddress,
  }) {
    return NextCollectionsEntity(
      type: type ?? this.type,
      cursor: cursor ?? this.cursor,
      nextWalletAddress: nextWalletAddress ?? this.nextWalletAddress,
    );
  }

  const NextCollectionsEntity.empty()
      : type = '',
        cursor = '',
        nextWalletAddress = '';
}

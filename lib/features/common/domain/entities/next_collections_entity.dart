import 'package:equatable/equatable.dart';

class NextCollectionsEntity extends Equatable {
  final String cursorType;
  final String cursor;
  final String nextWalletAddress;

  const NextCollectionsEntity({
    required this.cursorType,
    required this.cursor,
    required this.nextWalletAddress,
  });

  @override
  List<Object> get props => [cursorType, cursor, nextWalletAddress];

  NextCollectionsEntity copyWith({
    String? cursorType,
    String? cursor,
    String? nextWalletAddress,
  }) {
    return NextCollectionsEntity(
      cursorType: cursorType ?? this.cursorType,
      cursor: cursor ?? this.cursor,
      nextWalletAddress: nextWalletAddress ?? this.nextWalletAddress,
    );
  }

  const NextCollectionsEntity.empty()
      : cursorType = '',
        cursor = '',
        nextWalletAddress = '';
}

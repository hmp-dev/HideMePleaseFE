import 'package:equatable/equatable.dart';

class NftUsageHistoryEntity extends Equatable {
  final List<UsageHistoryItemEntity> items;
  final int count;

  const NftUsageHistoryEntity({
    required this.items,
    required this.count,
  });

  @override
  List<Object?> get props => [items, count];

  NftUsageHistoryEntity.empty()
      : items = [],
        count = 0;
}

class UsageHistoryItemEntity extends Equatable {
  final String id;
  final int pointsEarned;
  final String createdAt;
  final String spaceName;
  final String benefitDescription;
  final String type;

  const UsageHistoryItemEntity({
    required this.id,
    required this.pointsEarned,
    required this.createdAt,
    required this.spaceName,
    required this.benefitDescription,
    required this.type,
  });

  @override
  List<Object?> get props {
    return [
      id,
      pointsEarned,
      createdAt,
      spaceName,
      benefitDescription,
      type,
    ];
  }

  UsageHistoryItemEntity copyWith({
    String? id,
    int? pointsEarned,
    String? createdAt,
    String? spaceName,
    String? benefitDescription,
    String? type,
  }) {
    return UsageHistoryItemEntity(
      id: id ?? this.id,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      createdAt: createdAt ?? this.createdAt,
      spaceName: spaceName ?? this.spaceName,
      benefitDescription: benefitDescription ?? this.benefitDescription,
      type: type ?? this.type,
    );
  }

  const UsageHistoryItemEntity.empty()
      : id = '',
        pointsEarned = 0,
        createdAt = '',
        spaceName = '',
        benefitDescription = '',
        type = '';
}

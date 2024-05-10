import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/nft_usage_history_entity.dart';

part 'nft_usage_history_dto.g.dart';

@JsonSerializable()
class NftUsageHistoryDto extends Equatable {
  @JsonKey(name: "items")
  final List<UsageHistoryItem>? items;
  @JsonKey(name: "count")
  final int? count;

  const NftUsageHistoryDto({
    this.items,
    this.count,
  });

  factory NftUsageHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$NftUsageHistoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftUsageHistoryDtoToJson(this);

  @override
  List<Object?> get props => [items, count];

  NftUsageHistoryEntity toEntity() => NftUsageHistoryEntity(
        items: items?.map((e) => e.toEntity()).toList() ?? [],
        count: count ?? 0,
      );
}

@JsonSerializable()
class UsageHistoryItem extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "pointsEarned")
  final int? pointsEarned;
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @JsonKey(name: "spaceName")
  final String? spaceName;
  @JsonKey(name: "benefitDescription")
  final String? benefitDescription;
  @JsonKey(name: "type")
  final String? type;

  const UsageHistoryItem({
    this.id,
    this.pointsEarned,
    this.createdAt,
    this.spaceName,
    this.benefitDescription,
    this.type,
  });

  factory UsageHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$UsageHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$UsageHistoryItemToJson(this);

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

  UsageHistoryItemEntity toEntity() => UsageHistoryItemEntity(
        id: id ?? '',
        pointsEarned: pointsEarned ?? 0,
        createdAt: createdAt ?? '',
        spaceName: spaceName ?? '',
        benefitDescription: benefitDescription ?? '',
        type: type ?? '',
      );
}

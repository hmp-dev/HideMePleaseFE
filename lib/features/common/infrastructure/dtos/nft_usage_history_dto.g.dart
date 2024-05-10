// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_usage_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftUsageHistoryDto _$NftUsageHistoryDtoFromJson(Map<String, dynamic> json) =>
    NftUsageHistoryDto(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => UsageHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );

Map<String, dynamic> _$NftUsageHistoryDtoToJson(NftUsageHistoryDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'count': instance.count,
    };

UsageHistoryItem _$UsageHistoryItemFromJson(Map<String, dynamic> json) =>
    UsageHistoryItem(
      id: json['id'] as String?,
      pointsEarned: json['pointsEarned'] as int?,
      createdAt: json['createdAt'] as String?,
      spaceName: json['spaceName'] as String?,
      benefitDescription: json['benefitDescription'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$UsageHistoryItemToJson(UsageHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pointsEarned': instance.pointsEarned,
      'createdAt': instance.createdAt,
      'spaceName': instance.spaceName,
      'benefitDescription': instance.benefitDescription,
      'type': instance.type,
    };

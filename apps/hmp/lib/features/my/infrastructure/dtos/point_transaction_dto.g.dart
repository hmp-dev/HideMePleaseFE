// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointTransactionDto _$PointTransactionDtoFromJson(Map<String, dynamic> json) =>
    PointTransactionDto(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String,
      source: json['source'] as String,
      description: json['description'] as String,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      balanceBefore: (json['balanceBefore'] as num).toInt(),
      balanceAfter: (json['balanceAfter'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PointTransactionDtoToJson(
        PointTransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'userId': instance.userId,
      'amount': instance.amount,
      'type': instance.type,
      'source': instance.source,
      'description': instance.description,
      'referenceId': instance.referenceId,
      'referenceType': instance.referenceType,
      'balanceBefore': instance.balanceBefore,
      'balanceAfter': instance.balanceAfter,
      'metadata': instance.metadata,
    };

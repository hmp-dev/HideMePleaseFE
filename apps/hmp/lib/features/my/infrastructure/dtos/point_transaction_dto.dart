import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/my/domain/entities/point_transaction_entity.dart';

part 'point_transaction_dto.g.dart';

@JsonSerializable()
class PointTransactionDto extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'amount')
  final int amount;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'source')
  final String source;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'referenceId')
  final String? referenceId;

  @JsonKey(name: 'referenceType')
  final String? referenceType;

  @JsonKey(name: 'balanceBefore')
  final int balanceBefore;

  @JsonKey(name: 'balanceAfter')
  final int balanceAfter;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  const PointTransactionDto({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.amount,
    required this.type,
    required this.source,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.balanceBefore,
    required this.balanceAfter,
    this.metadata,
  });

  factory PointTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$PointTransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PointTransactionDtoToJson(this);

  PointTransactionEntity toEntity() {
    return PointTransactionEntity(
      id: id,
      createdAt: DateTime.parse(createdAt),
      userId: userId,
      amount: amount,
      type: _parseType(type),
      source: _parseSource(source),
      description: description,
      referenceId: referenceId,
      referenceType: referenceType,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      metadata: metadata,
    );
  }

  /// 백엔드 type 문자열을 enum으로 변환
  PointTransactionType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'EARNED':
        return PointTransactionType.EARNED;
      case 'SPENT':
        return PointTransactionType.SPENT;
      case 'REFUND':
        return PointTransactionType.REFUND;
      case 'ADJUSTMENT':
        return PointTransactionType.ADJUSTMENT;
      case 'LOCKED':
        return PointTransactionType.LOCKED;
      case 'UNLOCKED':
        return PointTransactionType.UNLOCKED;
      default:
        return PointTransactionType.EARNED; // 기본값
    }
  }

  /// 백엔드 source 문자열을 enum으로 변환
  PointTransactionSource _parseSource(String source) {
    switch (source.toUpperCase()) {
      case 'CHECK_IN':
        return PointTransactionSource.CHECK_IN;
      case 'GROUP_BONUS':
        return PointTransactionSource.GROUP_BONUS;
      case 'PURCHASE':
        return PointTransactionSource.PURCHASE;
      case 'REWARD':
        return PointTransactionSource.REWARD;
      case 'REFERRAL':
        return PointTransactionSource.REFERRAL;
      case 'EVENT':
        return PointTransactionSource.EVENT;
      case 'ADMIN_GRANT':
        return PointTransactionSource.ADMIN_GRANT;
      case 'ADMIN_DEDUCT':
        return PointTransactionSource.ADMIN_DEDUCT;
      case 'TRANSFER_IN':
        return PointTransactionSource.TRANSFER_IN;
      case 'TRANSFER_OUT':
        return PointTransactionSource.TRANSFER_OUT;
      case 'REFUND':
        return PointTransactionSource.REFUND;
      case 'SIREN_POST':
        return PointTransactionSource.SIREN_POST;
      case 'FRIEND_REQUEST':
        return PointTransactionSource.FRIEND_REQUEST;
      case 'FRIEND_ACCEPT':
        return PointTransactionSource.FRIEND_ACCEPT;
      case 'OTHER':
      default:
        return PointTransactionSource.OTHER;
    }
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        userId,
        amount,
        type,
        source,
        description,
        referenceId,
        referenceType,
        balanceBefore,
        balanceAfter,
        metadata,
      ];
}

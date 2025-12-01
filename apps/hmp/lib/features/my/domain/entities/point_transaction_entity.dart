import 'package:equatable/equatable.dart';

enum PointTransactionType {
  EARNED,
  SPENT,
  REFUND,
  ADJUSTMENT,
  LOCKED,
  UNLOCKED,
}

enum PointTransactionSource {
  CHECK_IN,
  GROUP_BONUS,
  PURCHASE,
  REWARD,
  REFERRAL,
  EVENT,
  ADMIN_GRANT,
  ADMIN_DEDUCT,
  TRANSFER_IN,
  TRANSFER_OUT,
  REFUND,
  SIREN_POST,
  FRIEND_REQUEST,
  FRIEND_ACCEPT,
  OTHER,
}

class PointTransactionEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final String userId;
  final int amount;
  final PointTransactionType type;
  final PointTransactionSource source;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final int balanceBefore;
  final int balanceAfter;
  final Map<String, dynamic>? metadata;

  const PointTransactionEntity({
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

  /// UI에 표시할 제목 생성
  String get displayTitle {
    final isEarn = type == PointTransactionType.EARNED;
    final prefix = isEarn ? 'SAV 획득' : 'SAV 사용';

    final sourceLabel = _getSourceLabel(source);
    return '$prefix [$sourceLabel]';
  }

  /// 소스별 한글 레이블 반환
  String _getSourceLabel(PointTransactionSource source) {
    switch (source) {
      case PointTransactionSource.CHECK_IN:
        return '매장 체크인';
      case PointTransactionSource.GROUP_BONUS:
        return '그룹 보너스';
      case PointTransactionSource.PURCHASE:
        return '구매';
      case PointTransactionSource.REWARD:
        return '리워드';
      case PointTransactionSource.REFERRAL:
        return '추천';
      case PointTransactionSource.EVENT:
        return '이벤트';
      case PointTransactionSource.ADMIN_GRANT:
        return '관리자 지급';
      case PointTransactionSource.ADMIN_DEDUCT:
        return '관리자 차감';
      case PointTransactionSource.TRANSFER_IN:
        return '받기';
      case PointTransactionSource.TRANSFER_OUT:
        return '보내기';
      case PointTransactionSource.REFUND:
        return '환불';
      case PointTransactionSource.SIREN_POST:
        return '사이렌';
      case PointTransactionSource.FRIEND_REQUEST:
        return '친구 요청';
      case PointTransactionSource.FRIEND_ACCEPT:
        return '친구 수락';
      case PointTransactionSource.OTHER:
        return '기타';
    }
  }

  /// 날짜 포맷 (YYYY/MM/DD HH:mm)
  String get formattedDate {
    final year = createdAt.year;
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$year/$month/$day  $hour:$minute';
  }

  /// 거래 금액의 절대값 (UI 표시용)
  int get absoluteAmount => amount.abs();

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

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/infrastructure/dtos/pagination_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/point_transaction_dto.dart';

part 'points_history_response_dto.g.dart';

@JsonSerializable()
class PointsHistoryResponseDto extends Equatable {
  @JsonKey(name: 'transactions')
  final List<PointTransactionDto> transactions;

  @JsonKey(name: 'pagination')
  final PaginationDto pagination;

  const PointsHistoryResponseDto({
    required this.transactions,
    required this.pagination,
  });

  factory PointsHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PointsHistoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PointsHistoryResponseDtoToJson(this);

  @override
  List<Object?> get props => [transactions, pagination];
}

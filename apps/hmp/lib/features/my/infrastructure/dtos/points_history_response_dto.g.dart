// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_history_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsHistoryResponseDto _$PointsHistoryResponseDtoFromJson(
        Map<String, dynamic> json) =>
    PointsHistoryResponseDto(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => PointTransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PointsHistoryResponseDtoToJson(
        PointsHistoryResponseDto instance) =>
    <String, dynamic>{
      'transactions': instance.transactions,
      'pagination': instance.pagination,
    };

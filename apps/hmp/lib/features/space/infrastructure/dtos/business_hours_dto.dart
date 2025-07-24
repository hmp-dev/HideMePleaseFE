import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';

part 'business_hours_dto.g.dart';

@JsonSerializable()
class BusinessHoursDto extends Equatable {
  @JsonKey(name: "dayOfWeek")
  final String? dayOfWeek;
  @JsonKey(name: "openTime")
  final String? openTime;
  @JsonKey(name: "closeTime")
  final String? closeTime;
  @JsonKey(name: "breakStartTime")
  final String? breakStartTime;
  @JsonKey(name: "breakEndTime")
  final String? breakEndTime;
  @JsonKey(name: "isClosed")
  final bool? isClosed;

  const BusinessHoursDto({
    this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.breakStartTime,
    this.breakEndTime,
    this.isClosed,
  });

  factory BusinessHoursDto.fromJson(Map<String, dynamic> json) =>
      _$BusinessHoursDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessHoursDtoToJson(this);

  @override
  List<Object?> get props => [
        dayOfWeek,
        openTime,
        closeTime,
        breakStartTime,
        breakEndTime,
        isClosed,
      ];

  BusinessHoursEntity toEntity() => BusinessHoursEntity(
        dayOfWeek: _parseDayOfWeek(dayOfWeek ?? ""),
        openTime: openTime,
        closeTime: closeTime,
        breakStartTime: breakStartTime,
        breakEndTime: breakEndTime,
        isClosed: isClosed ?? false,
      );

  DayOfWeek _parseDayOfWeek(String day) {
    switch (day.toUpperCase()) {
      case 'MONDAY':
        return DayOfWeek.MONDAY;
      case 'TUESDAY':
        return DayOfWeek.TUESDAY;
      case 'WEDNESDAY':
        return DayOfWeek.WEDNESDAY;
      case 'THURSDAY':
        return DayOfWeek.THURSDAY;
      case 'FRIDAY':
        return DayOfWeek.FRIDAY;
      case 'SATURDAY':
        return DayOfWeek.SATURDAY;
      case 'SUNDAY':
        return DayOfWeek.SUNDAY;
      default:
        return DayOfWeek.MONDAY;
    }
  }
}
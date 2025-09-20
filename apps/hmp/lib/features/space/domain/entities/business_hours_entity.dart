import 'package:equatable/equatable.dart';

enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}

class BusinessHoursEntity extends Equatable {
  final DayOfWeek dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final String? breakStartTime;
  final String? breakEndTime;
  final bool isClosed;

  const BusinessHoursEntity({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.breakStartTime,
    this.breakEndTime,
    required this.isClosed,
  });

  @override
  List<Object?> get props => [
        dayOfWeek,
        openTime,
        closeTime,
        breakStartTime,
        breakEndTime,
        isClosed,
      ];

  // Helper method to check if the store is open at a specific time
  bool isOpenAt(DateTime time) {
    if (isClosed || openTime == null || closeTime == null) {
      return false;
    }

    final now = time;
    final openParts = openTime!.split(':');
    final closeParts = closeTime!.split(':');

    final openHour = int.parse(openParts[0]);
    final openMinute = int.parse(openParts[1]);
    final closeHour = int.parse(closeParts[0]);
    final closeMinute = int.parse(closeParts[1]);

    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = openHour * 60 + openMinute;
    final closeMinutes = closeHour * 60 + closeMinute;

    // Check if within business hours (including closing time)
    bool isWithinBusinessHours = false;
    if (closeMinutes < openMinutes) {
      // Handles cases like 22:00 - 02:00 (across midnight)
      isWithinBusinessHours = currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    } else {
      isWithinBusinessHours = currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    }

    // Check if in break time
    if (isWithinBusinessHours && breakStartTime != null && breakEndTime != null) {
      final breakStartParts = breakStartTime!.split(':');
      final breakEndParts = breakEndTime!.split(':');
      final breakStartMinutes = int.parse(breakStartParts[0]) * 60 + int.parse(breakStartParts[1]);
      final breakEndMinutes = int.parse(breakEndParts[0]) * 60 + int.parse(breakEndParts[1]);

      if (currentMinutes >= breakStartMinutes && currentMinutes < breakEndMinutes) {
        return false; // During break time
      }
    }

    return isWithinBusinessHours;
  }
}
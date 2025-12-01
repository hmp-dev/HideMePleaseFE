import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/business_hours_entity.dart';
import 'package:mobile/features/space/domain/entities/space_event_category_entity.dart';

class SpaceEntity extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String image;
  final String category;
  final String benefitDescription;
  final String benefitDescriptionEn;
  final bool hot;
  final int hotPoints;
  final int hidingCount;
  final double latitude;
  final double longitude;
  final List<BusinessHoursEntity> businessHours;
  final bool isTemporarilyClosed;
  final List<SpaceEventCategoryEntity> spaceEventCategories;
  final String currentGroupProgress;
  final int maxCapacity;
  
  const SpaceEntity({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.image,
    required this.category,
    required this.benefitDescription,
    this.benefitDescriptionEn = '',
    required this.hot,
    required this.hotPoints,
    required this.hidingCount,
    required this.latitude,
    required this.longitude,
    this.businessHours = const [],
    this.isTemporarilyClosed = false,
    this.spaceEventCategories = const [],
    this.currentGroupProgress = '',
    this.maxCapacity = 0,
  });

  // Alias for maxCapacity to match API field name
  int get maxCheckInCapacity => maxCapacity;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      nameEn,
      image,
      category,
      benefitDescription,
      benefitDescriptionEn,
      hot,
      hotPoints,
      hidingCount,
      latitude,
      longitude,
      businessHours,
      isTemporarilyClosed,
      spaceEventCategories,
      currentGroupProgress,
      maxCapacity,
    ];
  }

  SpaceEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? image,
    String? category,
    String? benefitDescription,
    String? benefitDescriptionEn,
    bool? hot,
    int? hotPoints,
    int? hidingCount,
    double? latitude,
    double? longitude,
    List<BusinessHoursEntity>? businessHours,
    bool? isTemporarilyClosed,
    List<SpaceEventCategoryEntity>? spaceEventCategories,
    String? currentGroupProgress,
    int? maxCapacity,
  }) {
    return SpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      image: image ?? this.image,
      category: category ?? this.category,
      benefitDescription: benefitDescription ?? this.benefitDescription,
      benefitDescriptionEn: benefitDescriptionEn ?? this.benefitDescriptionEn,
      hot: hot ?? this.hot,
      hotPoints: hotPoints ?? this.hotPoints,
      hidingCount: hidingCount ?? this.hidingCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessHours: businessHours ?? this.businessHours,
      isTemporarilyClosed: isTemporarilyClosed ?? this.isTemporarilyClosed,
      spaceEventCategories: spaceEventCategories ?? this.spaceEventCategories,
      currentGroupProgress: currentGroupProgress ?? this.currentGroupProgress,
      maxCapacity: maxCapacity ?? this.maxCapacity,
    );
  }

  const SpaceEntity.empty()
      : id = '',
        name = '',
        nameEn = '',
        image = '',
        category = '',
        benefitDescription = '',
        benefitDescriptionEn = '',
        hot = false,
        hotPoints = 0,
        hidingCount = 0,
        latitude = 0.0,
        longitude = 0.0,
        businessHours = const [],
        isTemporarilyClosed = false,
        spaceEventCategories = const [],
        currentGroupProgress = '',
        maxCapacity = 0;

  // Helper method to check if the store is currently open
  bool get isCurrentlyOpen {
    if (isTemporarilyClosed) {
      return false;
    }

    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);
    
    // Find today's business hours
    final todayHours = businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    return todayHours.isOpenAt(now);
  }

  // Get next opening time
  String? get nextOpeningTime {
    if (isTemporarilyClosed) {
      return null;
    }

    final now = DateTime.now();
    final currentDay = _getDayOfWeekFromDateTime(now);
    
    // Check if opens later today
    final todayHours = businessHours.firstWhere(
      (hours) => hours.dayOfWeek == currentDay,
      orElse: () => BusinessHoursEntity(
        dayOfWeek: currentDay,
        isClosed: true,
      ),
    );

    if (!todayHours.isClosed && todayHours.openTime != null) {
      final openParts = todayHours.openTime!.split(':');
      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      final currentMinutes = now.hour * 60 + now.minute;
      final openMinutes = openHour * 60 + openMinute;

      if (currentMinutes < openMinutes) {
        return todayHours.openTime;
      }
    }

    // Find next open day
    for (int i = 1; i <= 7; i++) {
      final nextDay = DayOfWeek.values[(currentDay.index + i) % 7];
      final nextDayHours = businessHours.firstWhere(
        (hours) => hours.dayOfWeek == nextDay,
        orElse: () => BusinessHoursEntity(
          dayOfWeek: nextDay,
          isClosed: true,
        ),
      );

      if (!nextDayHours.isClosed && nextDayHours.openTime != null) {
        return nextDayHours.openTime;
      }
    }

    return null;
  }

  DayOfWeek _getDayOfWeekFromDateTime(DateTime dateTime) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    switch (dateTime.weekday) {
      case 1:
        return DayOfWeek.MONDAY;
      case 2:
        return DayOfWeek.TUESDAY;
      case 3:
        return DayOfWeek.WEDNESDAY;
      case 4:
        return DayOfWeek.THURSDAY;
      case 5:
        return DayOfWeek.FRIDAY;
      case 6:
        return DayOfWeek.SATURDAY;
      case 7:
        return DayOfWeek.SUNDAY;
      default:
        return DayOfWeek.MONDAY;
    }
  }
}

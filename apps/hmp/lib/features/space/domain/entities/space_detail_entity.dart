import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/checked_in_user_entity.dart';

class SpaceDetailEntity extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String businessHoursStart;
  final String businessHoursEnd;
  final String category;
  final String introduction;
  final String locationDescription;
  final String image;
  final int checkInCount;
  final bool spaceOpen;
  final List<CheckedInUserEntity> checkedInUsers;
  final String currentGroupProgress;

  const SpaceDetailEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.businessHoursStart,
    required this.businessHoursEnd,
    required this.category,
    required this.introduction,
    required this.locationDescription,
    required this.image,
    required this.checkInCount,
    required this.spaceOpen,
    this.checkedInUsers = const [],
    this.currentGroupProgress = '',
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      latitude,
      longitude,
      address,
      businessHoursStart,
      businessHoursEnd,
      category,
      introduction,
      locationDescription,
      image,
      checkInCount,
      spaceOpen,
      checkedInUsers,
      currentGroupProgress,
    ];
  }

  SpaceDetailEntity copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? businessHoursStart,
    String? businessHoursEnd,
    String? category,
    String? introduction,
    String? locationDescription,
    String? image,
    int? checkInCount,
    bool? spaceOpen,
    List<CheckedInUserEntity>? checkedInUsers,
    String? currentGroupProgress,
  }) {
    return SpaceDetailEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      businessHoursStart: businessHoursStart ?? this.businessHoursStart,
      businessHoursEnd: businessHoursEnd ?? this.businessHoursEnd,
      category: category ?? this.category,
      introduction: introduction ?? this.introduction,
      locationDescription: locationDescription ?? this.locationDescription,
      image: image ?? this.image,
      checkInCount: checkInCount ?? this.checkInCount,
      spaceOpen: spaceOpen ?? this.spaceOpen,
      checkedInUsers: checkedInUsers ?? this.checkedInUsers,
      currentGroupProgress: currentGroupProgress ?? this.currentGroupProgress,
    );
  }

  const SpaceDetailEntity.empty()
      : id = '',
        name = '',
        latitude = 0,
        longitude = 0,
        address = '',
        businessHoursStart = '',
        businessHoursEnd = '',
        category = '',
        introduction = '',
        locationDescription = '',
        image = '',
        checkInCount = 0,
        spaceOpen = false,
        checkedInUsers = const [],
        currentGroupProgress = '';
}

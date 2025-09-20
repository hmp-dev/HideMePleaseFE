import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/checked_in_user_entity.dart';

class SpaceDetailEntity extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final double latitude;
  final double longitude;
  final String address;
  final String addressEn;
  final String businessHoursStart;
  final String businessHoursEnd;
  final String category;
  final String introduction;
  final String introductionEn;
  final String locationDescription;
  final String image;
  final int checkInCount;
  final bool spaceOpen;
  final List<CheckedInUserEntity> checkedInUsers;
  final String currentGroupProgress;

  const SpaceDetailEntity({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.latitude,
    required this.longitude,
    required this.address,
    this.addressEn = '',
    required this.businessHoursStart,
    required this.businessHoursEnd,
    required this.category,
    required this.introduction,
    this.introductionEn = '',
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
      nameEn,
      latitude,
      longitude,
      address,
      addressEn,
      businessHoursStart,
      businessHoursEnd,
      category,
      introduction,
      introductionEn,
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
    String? nameEn,
    double? latitude,
    double? longitude,
    String? address,
    String? addressEn,
    String? businessHoursStart,
    String? businessHoursEnd,
    String? category,
    String? introduction,
    String? introductionEn,
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
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addressEn: addressEn ?? this.addressEn,
      businessHoursStart: businessHoursStart ?? this.businessHoursStart,
      businessHoursEnd: businessHoursEnd ?? this.businessHoursEnd,
      category: category ?? this.category,
      introduction: introduction ?? this.introduction,
      introductionEn: introductionEn ?? this.introductionEn,
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
        nameEn = '',
        latitude = 0,
        longitude = 0,
        address = '',
        addressEn = '',
        businessHoursStart = '',
        businessHoursEnd = '',
        category = '',
        introduction = '',
        introductionEn = '',
        locationDescription = '',
        image = '',
        checkInCount = 0,
        spaceOpen = false,
        checkedInUsers = const [],
        currentGroupProgress = '';
}

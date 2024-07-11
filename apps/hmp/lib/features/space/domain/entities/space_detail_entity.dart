import 'package:equatable/equatable.dart';

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
  final int hidingCount;

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
    required this.hidingCount,
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
      hidingCount,
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
    int? hidingCount,
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
      hidingCount: hidingCount ?? this.hidingCount,
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
        hidingCount = 0;
}

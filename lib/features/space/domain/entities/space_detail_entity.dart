import 'package:equatable/equatable.dart';

class SpaceDetailEntity extends Equatable {
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

  const SpaceDetailEntity({
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
  });

  @override
  List<Object?> get props {
    return [
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
    ];
  }

  SpaceDetailEntity copyWith({
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
  }) {
    return SpaceDetailEntity(
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
    );
  }

  const SpaceDetailEntity.empty()
      : name = '',
        latitude = 0,
        longitude = 0,
        address = '',
        businessHoursStart = '',
        businessHoursEnd = '',
        category = '',
        introduction = '',
        locationDescription = '',
        image = '';
}

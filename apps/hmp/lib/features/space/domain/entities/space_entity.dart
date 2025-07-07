import 'package:equatable/equatable.dart';

class SpaceEntity extends Equatable {
  final String id;
  final String name;
  final String image;
  final String category;
  final String benefitDescription;
  final bool hot;
  final int hotPoints;
  final int hidingCount;
  final double latitude;
  final double longitude;

  const SpaceEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.benefitDescription,
    required this.hot,
    required this.hotPoints,
    required this.hidingCount,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      category,
      benefitDescription,
      hot,
      hotPoints,
      hidingCount,
      latitude,
      longitude,
    ];
  }

  SpaceEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? category,
    String? benefitDescription,
    bool? hot,
    int? hotPoints,
    int? hidingCount,
    double? latitude,
    double? longitude,
  }) {
    return SpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      category: category ?? this.category,
      benefitDescription: benefitDescription ?? this.benefitDescription,
      hot: hot ?? this.hot,
      hotPoints: hotPoints ?? this.hotPoints,
      hidingCount: hidingCount ?? this.hidingCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  const SpaceEntity.empty()
      : id = '',
        name = '',
        image = '',
        category = '',
        benefitDescription = '',
        hot = false,
        hotPoints = 0,
        hidingCount = 0,
        latitude = 0.0,
        longitude = 0.0;
}

import 'package:equatable/equatable.dart';

class SpaceEntity extends Equatable {
  final String id;
  final String name;
  final String image;
  final String category;
  final bool hot;
  final int hotPoints;
  final int hidingCount;

  const SpaceEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.hot,
    required this.hotPoints,
    required this.hidingCount,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      category,
      hot,
      hotPoints,
      hidingCount,
    ];
  }

  SpaceEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? category,
    bool? hot,
    int? hotPoints,
    int? hidingCount,
  }) {
    return SpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      category: category ?? this.category,
      hot: hot ?? this.hot,
      hotPoints: hotPoints ?? this.hotPoints,
      hidingCount: hidingCount ?? this.hidingCount,
    );
  }

  const SpaceEntity.empty()
      : id = '',
        name = '',
        image = '',
        category = '',
        hot = false,
        hotPoints = 0,
        hidingCount = 0;
}

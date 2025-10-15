import 'package:equatable/equatable.dart';

class SirenSpaceEntity extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String image;
  final double latitude;
  final double longitude;
  final String category;

  const SirenSpaceEntity({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  const SirenSpaceEntity.empty()
      : id = '',
        name = '',
        nameEn = '',
        image = '',
        latitude = 0.0,
        longitude = 0.0,
        category = '';

  @override
  List<Object?> get props => [id, name, nameEn, image, latitude, longitude, category];
}

import 'package:equatable/equatable.dart';

class NearBySpaceEntity extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String image;
  final int distance;

  const NearBySpaceEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.image,
    required this.distance,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      latitude,
      longitude,
      address,
      image,
      distance,
    ];
  }

  const NearBySpaceEntity.empty()
      : id = '',
        name = '',
        latitude = 0.0,
        longitude = 0.0,
        address = '',
        image = '',
        distance = 0;

  NearBySpaceEntity copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? image,
    int? distance,
  }) {
    return NearBySpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      image: image ?? this.image,
      distance: distance ?? this.distance,
    );
  }
}

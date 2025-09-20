import 'package:equatable/equatable.dart';

/// Represents a space location that is nearby the user's current location.
///
/// This class contains information about the space such as its id, name,
/// latitude, longitude, address, image, and distance from the user's current
/// location.
class NearBySpaceEntity extends Equatable {
  /// The unique identifier of the space.
  final String id;

  /// The name of the space.
  final String name;

  /// The English name of the space.
  final String nameEn;

  /// The latitude of the space's location.
  final double latitude;

  /// The longitude of the space's location.
  final double longitude;

  /// The address of the space.
  final String address;

  /// The image of the space.
  final String image;

  /// The distance from the user's current location to the space.
  final int distance;

  /// Creates a [NearBySpaceEntity] with the given [id], [name], [nameEn], [latitude],
  /// [longitude], [address], [image], and [distance].
  const NearBySpaceEntity({
    required this.id,
    required this.name,
    this.nameEn = '',
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.image,
    required this.distance,
  });

  /// The properties that are used for equality comparison.
  @override
  List<Object?> get props {
    return [
      id,
      name,
      nameEn,
      latitude,
      longitude,
      address,
      image,
      distance,
    ];
  }

  /// Creates a new [NearBySpaceEntity] with default values.
  const NearBySpaceEntity.empty()
      : id = '',
        name = '',
        nameEn = '',
        latitude = 0.0,
        longitude = 0.0,
        address = '',
        image = '',
        distance = 0;

  /// Creates a new [NearBySpaceEntity] with the given [id], [name], [nameEn], [latitude],
  /// [longitude], [address], [image], and [distance]. If any of the values are
  /// null, the corresponding value from the current [NearBySpaceEntity] is used.
  NearBySpaceEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    double? latitude,
    double? longitude,
    String? address,
    String? image,
    int? distance,
  }) {
    return NearBySpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      image: image ?? this.image,
      distance: distance ?? this.distance,
    );
  }
}

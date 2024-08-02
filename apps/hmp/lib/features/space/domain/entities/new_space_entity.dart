import 'package:equatable/equatable.dart';

/// Represents a new space entity.
///
/// This class holds the data associated with a new space. It contains the
/// id, name, image, main benefit description, remaining benefit count, and
/// hiding count of the space.
class NewSpaceEntity extends Equatable {
  /// Unique identifier of the space.
  final String id;

  /// Name of the space.
  final String name;

  /// Image URL of the space.
  final String image;

  /// Description of the main benefit of the space.
  final String mainBenefitDescription;

  /// Remaining benefit count of the space.
  final int remainingBenefitCount;

  /// Hiding count of the space.
  final int hidingCount;

  /// Constructs a new [NewSpaceEntity] instance.
  ///
  /// All parameters are required.
  const NewSpaceEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.mainBenefitDescription,
    required this.remainingBenefitCount,
    required this.hidingCount,
  });

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      mainBenefitDescription,
      remainingBenefitCount,
      hidingCount,
    ];
  }

  /// Creates a copy of the [NewSpaceEntity] instance with the given parameters.
  ///
  /// If a parameter is not provided, the corresponding value from the current
  /// instance is used.
  NewSpaceEntity copyWith({
    String? id,
    String? name,
    String? image,
    String? mainBenefitDescription,
    int? remainingBenefitCount,
    int? hidingCount,
  }) {
    return NewSpaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      mainBenefitDescription:
          mainBenefitDescription ?? this.mainBenefitDescription,
      remainingBenefitCount:
          remainingBenefitCount ?? this.remainingBenefitCount,
      hidingCount: hidingCount ?? this.hidingCount,
    );
  }

  /// Constructs an empty [NewSpaceEntity] instance.
  ///
  /// All properties are initialized with empty values.
  const NewSpaceEntity.empty()
      : id = '',
        name = '',
        image = '',
        mainBenefitDescription = '',
        remainingBenefitCount = 0,
        hidingCount = 0;
}

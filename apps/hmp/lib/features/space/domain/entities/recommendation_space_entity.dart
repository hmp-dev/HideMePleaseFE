import 'package:equatable/equatable.dart';

/// Represents a recommended space entity.
///
/// This entity contains information about a recommended space,
/// such as its ID, name, and the number of users.
class RecommendationSpaceEntity extends Equatable {
  /// Unique identifier of the space.
  final String spaceId;

  /// Name of the space.
  final String spaceName;

  /// Number of users in the space.
  final int users;

  /// Constructs a [RecommendationSpaceEntity] with the given parameters.
  const RecommendationSpaceEntity({
    required this.spaceId,
    required this.spaceName,
    required this.users,
  });

  /// Returns the list of object properties that define the identity of the object.
  @override
  List<Object?> get props => [spaceId, spaceName, users];

  /// Returns a copy of this entity with the given parameters replaced by the new values.
  ///
  /// If a parameter is not provided, the corresponding property of this entity is used.
  RecommendationSpaceEntity copyWith({
    String? spaceId,
    String? spaceName,
    int? users,
  }) {
    return RecommendationSpaceEntity(
      spaceId: spaceId ?? this.spaceId,
      spaceName: spaceName ?? this.spaceName,
      users: users ?? this.users,
    );
  }

  /// Constructs an empty [RecommendationSpaceEntity].
  ///
  /// All properties are initialized to empty values.
  const RecommendationSpaceEntity.empty()
      : spaceId = '',
        spaceName = '',
        users = 0;
}

import 'package:equatable/equatable.dart';

class RecommendationSpaceEntity extends Equatable {
  final String spaceId;
  final String spaceName;
  final int users;

  const RecommendationSpaceEntity({
    required this.spaceId,
    required this.spaceName,
    required this.users,
  });

  @override
  List<Object?> get props => [spaceId, spaceName, users];

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

  const RecommendationSpaceEntity.empty()
      : spaceId = '',
        spaceName = '',
        users = 0;
}

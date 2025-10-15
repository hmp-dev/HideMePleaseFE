import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/siren_author_entity.dart';
import 'package:mobile/features/space/domain/entities/siren_space_entity.dart';

class SirenEntity extends Equatable {
  final String id;
  final String message;
  final String createdAt;
  final String expiresAt;
  final int pointsSpent;
  final int remainingDays;
  final SirenSpaceEntity? space;
  final SirenAuthorEntity? author;
  final double distance;

  const SirenEntity({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.expiresAt,
    required this.pointsSpent,
    required this.remainingDays,
    this.space,
    this.author,
    required this.distance,
  });

  const SirenEntity.empty()
      : id = '',
        message = '',
        createdAt = '',
        expiresAt = '',
        pointsSpent = 0,
        remainingDays = 0,
        space = null,
        author = null,
        distance = 0.0;

  @override
  List<Object?> get props => [
        id,
        message,
        createdAt,
        expiresAt,
        pointsSpent,
        remainingDays,
        space,
        author,
        distance,
      ];
}

import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final String id;
  final String createdAt;
  final String title;
  final String description;

  const AnnouncementEntity({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        title,
        description,
      ];

  const AnnouncementEntity.empty()
      : id = '',
        createdAt = '',
        title = '',
        description = '';

  AnnouncementEntity copyWith({
    String? id,
    String? createdAt,
    String? title,
    String? description,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

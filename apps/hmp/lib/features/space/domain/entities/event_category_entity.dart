import 'package:equatable/equatable.dart';

class EventCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? descriptionEn;
  final int displayOrder;
  final bool isActive;
  final String? colorCode;
  final String? iconUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventCategoryEntity({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.descriptionEn,
    required this.displayOrder,
    required this.isActive,
    this.colorCode,
    this.iconUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        nameEn,
        description,
        descriptionEn,
        displayOrder,
        isActive,
        colorCode,
        iconUrl,
        createdAt,
        updatedAt,
      ];

  EventCategoryEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    int? displayOrder,
    bool? isActive,
    String? colorCode,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      colorCode: colorCode ?? this.colorCode,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  const EventCategoryEntity.empty()
      : id = '',
        name = '',
        nameEn = null,
        description = null,
        descriptionEn = null,
        displayOrder = 0,
        isActive = false,
        colorCode = null,
        iconUrl = null,
        createdAt = null,
        updatedAt = null;
}
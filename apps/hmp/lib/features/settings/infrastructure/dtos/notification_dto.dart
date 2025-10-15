import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/settings/domain/entities/notification_entity.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationDto extends Equatable {
  final String? id;
  final String? createdAt;
  final String? title;
  final String? body;
  final String? type;
  final Map<String, dynamic>? params;
  final bool? isRead;

  const NotificationDto({
    this.id,
    this.createdAt,
    this.title,
    this.body,
    this.type,
    this.params,
    this.isRead,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      createdAt,
      title,
      body,
      type,
      params,
      isRead,
    ];
  }

  NotificationEntity toEntity() => NotificationEntity(
        id: id!,
        createdAt: createdAt ?? '',
        title: title ?? '',
        body: body ?? '',
        type: type ?? '',
        params: params ?? {},
        isRead: isRead ?? false,
      );
}

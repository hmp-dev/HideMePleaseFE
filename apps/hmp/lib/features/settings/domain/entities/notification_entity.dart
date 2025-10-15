import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String createdAt;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> params;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.body,
    required this.type,
    required this.params,
    required this.isRead,
  });

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

  const NotificationEntity.empty()
      : id = '',
        createdAt = '',
        title = '',
        body = '',
        type = '',
        params = const {},
        isRead = false;

  NotificationEntity copyWith({
    String? id,
    String? createdAt,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? params,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      params: params ?? this.params,
      isRead: isRead ?? this.isRead,
    );
  }
}

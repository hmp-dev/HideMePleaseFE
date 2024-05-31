import 'package:equatable/equatable.dart';

class BaseUserEntity extends Equatable {
  final String id;
  final String wldNullifierHash;
  final String firebaseId;

  const BaseUserEntity({
    required this.id,
    required this.wldNullifierHash,
    required this.firebaseId,
  });

  const BaseUserEntity.empty()
      : id = '',
        wldNullifierHash = '',
        firebaseId = '';

  @override
  List<Object> get props {
    return [
      id,
      wldNullifierHash,
      firebaseId,
    ];
  }

  BaseUserEntity copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    bool? deleted,
    String? wldNullifierHash,
    String? firebaseId,
  }) {
    return BaseUserEntity(
      id: id ?? this.id,
      wldNullifierHash: wldNullifierHash ?? this.wldNullifierHash,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }
}

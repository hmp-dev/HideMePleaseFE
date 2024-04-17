import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final bool deleted;
  final String wldNullifierHash;
  final String firebaseId;

  const UserEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.wldNullifierHash,
    required this.firebaseId,
  });

  const UserEntity.empty()
      : id = '',
        createdAt = '',
        updatedAt = '',
        deleted = true,
        wldNullifierHash = '',
        firebaseId = '';

  @override
  List<Object> get props {
    return [
      id,
      createdAt,
      updatedAt,
      deleted,
      wldNullifierHash,
      firebaseId,
    ];
  }

  UserEntity copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    bool? deleted,
    String? wldNullifierHash,
    String? firebaseId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      wldNullifierHash: wldNullifierHash ?? this.wldNullifierHash,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }
}

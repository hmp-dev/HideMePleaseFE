// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/user_entity.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @JsonKey(name: "deleted")
  final bool? deleted;
  @JsonKey(name: "wldNullifierHash")
  final String? wldNullifierHash;
  @JsonKey(name: "firebaseId")
  final String? firebaseId;

  const UserDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deleted,
    this.wldNullifierHash,
    this.firebaseId,
  });

  UserEntity toEntity() => UserEntity(
        id: id!,
        updatedAt: updatedAt ?? '',
        createdAt: createdAt ?? '',
        deleted: deleted ?? false,
        wldNullifierHash: wldNullifierHash ?? '',
        firebaseId: firebaseId ?? '',
      );

  //

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      createdAt,
      updatedAt,
      deleted,
      wldNullifierHash,
      firebaseId,
    ];
  }
}

extension UserDtoExtension on UserDto? {
  bool get isEmpty => this == null;

  bool get isNotEmpty => this != null;
}

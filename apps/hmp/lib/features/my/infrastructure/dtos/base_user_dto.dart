// ignore_for_file: unused_import

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/my/domain/entities/base_user_entity.dart';

part 'base_user_dto.g.dart';

@JsonSerializable()
class BaseUserDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "wldNullifierHash")
  final String? wldNullifierHash;
  @JsonKey(name: "firebaseId")
  final String? firebaseId;

  const BaseUserDto({
    this.id,
    this.wldNullifierHash,
    this.firebaseId,
  });

  BaseUserEntity toEntity() => BaseUserEntity(
        id: id!,
        wldNullifierHash: wldNullifierHash ?? '',
        firebaseId: firebaseId ?? '',
      );

  //

  factory BaseUserDto.fromJson(Map<String, dynamic> json) =>
      _$BaseUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BaseUserDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      wldNullifierHash,
      firebaseId,
    ];
  }
}

extension UserDtoExtension on BaseUserDto? {
  bool get isEmpty => this == null;

  bool get isNotEmpty => this != null;
}

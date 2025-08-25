import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/checked_in_user_entity.dart';

part 'checked_in_user_dto.g.dart';

@JsonSerializable()
class CheckedInUserDto extends Equatable {
  @JsonKey(name: "userId")
  final String? userId;
  @JsonKey(name: "nickName")
  final String? nickName;
  @JsonKey(name: "checkedInAt")
  final String? checkedInAt;

  const CheckedInUserDto({
    this.userId,
    this.nickName,
    this.checkedInAt,
  });

  factory CheckedInUserDto.fromJson(Map<String, dynamic> json) =>
      _$CheckedInUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckedInUserDtoToJson(this);

  @override
  List<Object?> get props => [userId, nickName, checkedInAt];

  CheckedInUserEntity toEntity() => CheckedInUserEntity(
        userId: userId ?? "",
        nickName: nickName ?? "",
        checkedInAt: checkedInAt != null
            ? DateTime.parse(checkedInAt!)
            : DateTime.now(),
      );
}

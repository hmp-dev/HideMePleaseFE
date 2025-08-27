import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/space/domain/entities/check_in_user_entity.dart';

part 'check_in_user_dto.g.dart';

@JsonSerializable()
class CheckInUserDto {
  final String userId;
  final String nickName;
  final String? profileImageUrl;
  final DateTime checkedInAt;

  CheckInUserDto({
    required this.userId,
    required this.nickName,
    this.profileImageUrl,
    required this.checkedInAt,
  });

  factory CheckInUserDto.fromJson(Map<String, dynamic> json) =>
      _$CheckInUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInUserDtoToJson(this);

  CheckInUserEntity toEntity() {
    return CheckInUserEntity(
      userId: userId,
      nickName: nickName,
      profileImageUrl: profileImageUrl ?? '',
      checkedInAt: checkedInAt,
    );
  }
}

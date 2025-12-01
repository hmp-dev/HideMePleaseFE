import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/active_check_in_entity.dart';

part 'active_check_in_dto.g.dart';

@JsonSerializable()
class ActiveCheckInDto extends Equatable {
  @JsonKey(name: 'spaceId')
  final String spaceId;

  @JsonKey(name: 'spaceName')
  final String spaceName;

  @JsonKey(name: 'checkedInAt')
  final String checkedInAt;

  const ActiveCheckInDto({
    required this.spaceId,
    required this.spaceName,
    required this.checkedInAt,
  });

  factory ActiveCheckInDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveCheckInDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveCheckInDtoToJson(this);

  ActiveCheckInEntity toEntity() {
    return ActiveCheckInEntity(
      spaceId: spaceId,
      spaceName: spaceName,
      checkedInAt: DateTime.parse(checkedInAt),
    );
  }

  @override
  List<Object?> get props => [spaceId, spaceName, checkedInAt];
}

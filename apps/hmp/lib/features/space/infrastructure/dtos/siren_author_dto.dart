import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_author_entity.dart';

part 'siren_author_dto.g.dart';

@JsonSerializable()
class SirenAuthorDto extends Equatable {
  @JsonKey(name: "userId")
  final String? userId;

  @JsonKey(name: "nickName")
  final String? nickName;

  @JsonKey(name: "profileImageUrl")
  final String? profileImageUrl;

  @JsonKey(name: "finalProfileImageUrl")
  final String? finalProfileImageUrl;

  @JsonKey(name: "pfpImageUrl")
  final String? pfpImageUrl;

  const SirenAuthorDto({
    this.userId,
    this.nickName,
    this.profileImageUrl,
    this.finalProfileImageUrl,
    this.pfpImageUrl,
  });

  factory SirenAuthorDto.fromJson(Map<String, dynamic> json) =>
      _$SirenAuthorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenAuthorDtoToJson(this);

  SirenAuthorEntity toEntity() {
    // profileImageUrl이 없으면 userId로 동적 URL 생성
    final imageUrl = finalProfileImageUrl ??
                     pfpImageUrl ??
                     profileImageUrl ??
                     (userId != null && userId!.isNotEmpty
                       ? 'https://dev-api.hidemeplease.xyz/v1/public/nft/user/$userId/image'
                       : '');

    return SirenAuthorEntity(
      userId: userId ?? '',
      nickName: nickName ?? '',
      profileImageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, finalProfileImageUrl, pfpImageUrl];
}

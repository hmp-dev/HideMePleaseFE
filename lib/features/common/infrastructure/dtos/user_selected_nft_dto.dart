import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/common/domain/entities/user_selected_nft_entity.dart';

part 'user_selected_nft_dto.g.dart';

@JsonSerializable()
class UserSelectedNftDto extends Equatable {
  @JsonKey(name: "nftImageUrl")
  final String? nftImageUrl;
  @JsonKey(name: "nftId")
  final String? nftId;

  const UserSelectedNftDto({
    this.nftImageUrl,
    this.nftId,
  });

  factory UserSelectedNftDto.fromJson(Map<String, dynamic> json) =>
      _$UserSelectedNftDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSelectedNftDtoToJson(this);

  @override
  List<Object?> get props => [
        nftImageUrl,
        nftId,
      ];

  UserSelectedNftEntity toEntity() => UserSelectedNftEntity(
        nftImageUrl: nftImageUrl ?? '',
        nftId: nftId ?? '',
      );
}

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/settings/domain/entities/cms_link_entity.dart';

part 'cms_link_dto.g.dart';

@JsonSerializable()
class CmsLinkDto extends Equatable {
  @JsonKey(name: "link")
  final String? link;

  const CmsLinkDto({
    this.link,
  });

  factory CmsLinkDto.fromJson(Map<String, dynamic> json) =>
      _$CmsLinkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CmsLinkDtoToJson(this);

  @override
  List<Object?> get props => [link];

  CmsLinkEntity toEntity() => CmsLinkEntity(
        link: link ?? "",
      );
}

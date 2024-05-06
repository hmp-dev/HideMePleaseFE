import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/common/domain/entities/nft_collections_group_entity.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_collection_dto.dart';

part 'nft_collections_group_dto.g.dart';

@JsonSerializable()
class NftCollectionsGroupDto extends Equatable {
  @JsonKey(name: "collections")
  final List<NftCollectionDto>? collections;
  @JsonKey(name: "selectedNftCount")
  final int? selectedNftCount;
  @JsonKey(name: "next")
  final String? next;

  const NftCollectionsGroupDto({
    this.collections,
    this.selectedNftCount,
    this.next,
  });

  factory NftCollectionsGroupDto.fromJson(Map<String, dynamic> json) =>
      _$NftCollectionsGroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCollectionsGroupDtoToJson(this);

  @override
  List<Object?> get props => [collections, next];

  NftCollectionsGroupEntity toEntity() {
    return NftCollectionsGroupEntity(
      collections: collections?.map((dto) => dto.toEntity()).toList() ?? [],
      selectedNftCount: selectedNftCount ?? 0,
      next: next ?? '',
    );
  }
}

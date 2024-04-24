import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/selected_nft_entity.dart';

part 'selected_nft_dto.g.dart';

@JsonSerializable()
class SelectedNFTDto extends Equatable {
  final String? id;
  final int? order;
  final String? name;
  final String? symbol;
  @JsonKey(name: 'collectionLogo')
  final String? collectionLogoUrl;
  final String? chain;
  @JsonKey(name: 'nftName')
  final String? nftName;
  @JsonKey(name: 'nftImageUrl')
  final String? nftImageUrl;

  const SelectedNFTDto({
    this.id,
    this.order,
    this.name,
    this.symbol,
    this.collectionLogoUrl,
    this.chain,
    this.nftName,
    this.nftImageUrl,
  });

  factory SelectedNFTDto.fromJson(Map<String, dynamic> json) =>
      _$SelectedNFTDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedNFTDtoToJson(this);

  @override
  List<Object?> get props =>
      [id, order, name, symbol, collectionLogoUrl, chain, nftName, nftImageUrl];

  SelectedNFTEntity toEntity() => SelectedNFTEntity(
        id: id ?? "",
        order: order ?? 0,
        name: name ?? '',
        symbol: symbol ?? '',
        collectionLogoUrl: collectionLogoUrl ?? '',
        chain: chain ?? "",
        nftName: nftName ?? "",
        nftImageUrl: nftImageUrl ?? "",
      );
}

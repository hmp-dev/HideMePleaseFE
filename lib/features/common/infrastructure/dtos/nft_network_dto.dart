import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/nft_network_entity.dart';

part 'nft_network_dto.g.dart';

@JsonSerializable()
class NftNetworkDto extends Equatable {
  @JsonKey(name: "network")
  final String? network;
  @JsonKey(name: "holderCount")
  final String? holderCount;
  @JsonKey(name: "floorPrice")
  final int? floorPrice;

  const NftNetworkDto({
    this.network,
    this.holderCount,
    this.floorPrice,
  });

  factory NftNetworkDto.fromJson(Map<String, dynamic> json) =>
      _$NftNetworkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftNetworkDtoToJson(this);

  @override
  List<Object?> get props => [network, holderCount, floorPrice];

  NftNetworkEntity toEntity() => NftNetworkEntity(
        network: network ?? '',
        holderCount: holderCount ?? '',
        floorPrice: floorPrice ?? 0,
      );
}

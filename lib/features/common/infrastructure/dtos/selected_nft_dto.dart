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
  final String? chain;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  const SelectedNFTDto({
    this.id,
    this.order,
    this.name,
    this.symbol,
    this.chain,
    this.imageUrl,
  });

  factory SelectedNFTDto.fromJson(Map<String, dynamic> json) =>
      _$SelectedNFTDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedNFTDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        symbol,
        chain,
        imageUrl,
      ];

  SelectedNFTEntity toEntity() => SelectedNFTEntity(
        id: id ?? "",
        order: order ?? 0,
        name: name ?? '',
        symbol: symbol ?? '',
        chain: chain ?? "",
        imageUrl: imageUrl ?? "",
      );
}

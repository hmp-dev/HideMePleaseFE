import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/home/domain/entities/connected_wallet_entity.dart';

part 'connected_wallet_dto.g.dart';

@JsonSerializable()
class ConnectedWalletDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "deleted")
  final bool? deleted;
  @JsonKey(name: "userId")
  final String? userId;
  @JsonKey(name: "publicAddress")
  final String? publicAddress;
  @JsonKey(name: "provider")
  final String? provider;

  const ConnectedWalletDto({
    this.id,
    this.deleted,
    this.userId,
    this.publicAddress,
    this.provider,
  });

  factory ConnectedWalletDto.fromJson(Map<String, dynamic> json) =>
      _$ConnectedWalletDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectedWalletDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      deleted,
      userId,
      publicAddress,
      provider,
    ];
  }

  ConnectedWalletEntity toEntity() => ConnectedWalletEntity(
        id: id!,
        deleted: deleted ?? false,
        userId: userId ?? '',
        publicAddress: publicAddress ?? '',
        provider: provider ?? '',
      );
}

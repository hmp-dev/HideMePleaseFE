import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/wallets/domain/entities/connected_wallet_entity.dart';

part 'connected_wallet_dto.g.dart';

@JsonSerializable()

/// Represents a connected wallet DTO.
///
/// This class is used to serialize and deserialize connected wallet data from
/// and to JSON.
class ConnectedWalletDto extends Equatable {
  /// The unique identifier of the connected wallet.
  @JsonKey(name: "id")
  final String? id;

  /// Indicates whether the connected wallet has been deleted.
  @JsonKey(name: "deleted")
  final bool? deleted;

  /// The ID of the user associated with the connected wallet.
  @JsonKey(name: "userId")
  final String? userId;

  /// The public address of the connected wallet.
  @JsonKey(name: "publicAddress")
  final String? publicAddress;

  /// The provider of the connected wallet.
  @JsonKey(name: "provider")
  final String? provider;

  /// Initializes a new instance of the [ConnectedWalletDto] class.
  ///
  /// The [id], [deleted], [userId], [publicAddress], and [provider]
  /// parameters are used to set the values of the corresponding fields.
  const ConnectedWalletDto({
    this.id,
    this.deleted,
    this.userId,
    this.publicAddress,
    this.provider,
  });

  /// Creates a new instance of the [ConnectedWalletDto] class from a JSON map.
  ///
  /// The [json] parameter contains the JSON map used to deserialize the
  /// connected wallet data.
  factory ConnectedWalletDto.fromJson(Map<String, dynamic> json) =>
      _$ConnectedWalletDtoFromJson(json);

  /// Converts the [ConnectedWalletDto] instance into a JSON map.
  ///
  /// The returned map contains the serialized connected wallet data.
  Map<String, dynamic> toJson() => _$ConnectedWalletDtoToJson(this);

  /// Returns the list of objects used to determine the equality of objects of
  /// this class.
  ///
  /// The returned list contains the values of the [id], [deleted], [userId],
  /// [publicAddress], and [provider] fields.
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

  /// Converts the connected wallet DTO to the corresponding entity.
  ///
  /// The returned [ConnectedWalletEntity] instance contains the values of the
  /// [id], [deleted], [userId], [publicAddress], and [provider] fields.
  ConnectedWalletEntity toEntity() => ConnectedWalletEntity(
        id: id!,
        deleted: deleted ?? false,
        userId: userId ?? '',
        publicAddress: publicAddress ?? '',
        provider: provider ?? '',
      );
}

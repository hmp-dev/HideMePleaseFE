// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connected_wallet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectedWalletDto _$ConnectedWalletDtoFromJson(Map<String, dynamic> json) =>
    ConnectedWalletDto(
      id: json['id'] as String?,
      deleted: json['deleted'] as bool?,
      userId: json['userId'] as String?,
      publicAddress: json['publicAddress'] as String?,
      provider: json['provider'] as String?,
    );

Map<String, dynamic> _$ConnectedWalletDtoToJson(ConnectedWalletDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deleted': instance.deleted,
      'userId': instance.userId,
      'publicAddress': instance.publicAddress,
      'provider': instance.provider,
    };

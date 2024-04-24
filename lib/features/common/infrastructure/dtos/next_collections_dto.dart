import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/next_collections_entity.dart';

part 'next_collections_dto.g.dart';

@JsonSerializable()
class NextCollectionsDto extends Equatable {
  @JsonKey(name: "type")
  final String? type;
  @JsonKey(name: "cursor")
  final String? cursor;
  @JsonKey(name: "nextWalletAddress")
  final String? nextWalletAddress;

  const NextCollectionsDto({
    this.type,
    this.cursor,
    this.nextWalletAddress,
  });

  factory NextCollectionsDto.fromJson(Map<String, dynamic> json) =>
      _$NextCollectionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NextCollectionsDtoToJson(this);

  @override
  List<Object?> get props => [type, cursor, nextWalletAddress];

  NextCollectionsEntity toEntity() {
    return NextCollectionsEntity(
      type: type ?? '',
      cursor: cursor ?? '',
      nextWalletAddress: nextWalletAddress ?? '',
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/common/domain/entities/next_collections_entity.dart';
import 'package:mobile/features/common/domain/entities/nft_collection_entity.dart';

class NftCollectionsGroupEntity extends Equatable {
  final List<NftCollectionEntity> collections;
  final NextCollectionsEntity next;

  const NftCollectionsGroupEntity({
    required this.collections,
    required this.next,
  });

  @override
  List<Object> get props => [collections, next];

  NftCollectionsGroupEntity copyWith({
    List<NftCollectionEntity>? collections,
    NextCollectionsEntity? next,
  }) {
    return NftCollectionsGroupEntity(
      collections: collections ?? this.collections,
      next: next ?? this.next,
    );
  }

  NftCollectionsGroupEntity.empty()
      : collections = [],
        next = const NextCollectionsEntity.empty();
}

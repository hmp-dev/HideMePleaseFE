import 'package:equatable/equatable.dart';

import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/nft/domain/entities/nft_collection_entity.dart';

class NftCollectionsGroupEntity extends Equatable {
  final List<NftCollectionEntity> collections;
  final int selectedNftCount;
  final String next;

  const NftCollectionsGroupEntity({
    required this.collections,
    required this.selectedNftCount,
    required this.next,
  });

  @override
  List<Object> get props => [collections, next];

  NftCollectionsGroupEntity copyWith({
    List<NftCollectionEntity>? collections,
    int? selectedNftCount,
    String? next,
  }) {
    return NftCollectionsGroupEntity(
      collections: collections ?? this.collections,
      selectedNftCount: selectedNftCount ?? this.selectedNftCount,
      next: next ?? this.next,
    );
  }

  NftCollectionsGroupEntity.empty()
      : collections = [],
        selectedNftCount = 0,
        next = '';

  @override
  String toString() =>
      'NftCollectionsGroupEntity(collections: $collections, selectedNftCount: $selectedNftCount, next: $next)';
}

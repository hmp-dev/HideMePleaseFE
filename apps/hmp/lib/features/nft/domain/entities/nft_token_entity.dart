import 'package:equatable/equatable.dart';

class NftTokenEntity extends Equatable {
  final String id;
  final String tokenId;
  final String name;
  final String imageUrl;
  final String videoUrl;
  final bool selected;
  final String updatedAt;

  const NftTokenEntity({
    required this.id,
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.videoUrl,
    required this.selected,
    required this.updatedAt,
  });

  const NftTokenEntity.empty()
      : id = '',
        tokenId = '',
        name = '',
        imageUrl = '',
        videoUrl = '',
        selected = false,
        updatedAt = '';

  @override
  List<Object?> get props => [tokenId, name, imageUrl, videoUrl, selected];

  NftTokenEntity copyWith({
    String? id,
    String? tokenId,
    String? name,
    String? imageUrl,
    String? videoUrl,
    bool? selected,
    String? updatedAt,
  }) {
    return NftTokenEntity(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      selected: selected ?? this.selected,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NftTokenEntity(id: $id, tokenId: $tokenId, name: $name, imageUrl: $imageUrl, videoUrl: $videoUrl, selected: $selected, updatedAt: $updatedAt)';
  }
}

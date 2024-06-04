import 'package:equatable/equatable.dart';

class CmsLinkEntity extends Equatable {
  final String link;

  const CmsLinkEntity({
    required this.link,
  });

  @override
  List<Object?> get props => [link];

  const CmsLinkEntity.empty() : link = '';

  CmsLinkEntity copyWith({
    String? link,
  }) {
    return CmsLinkEntity(
      link: link ?? this.link,
    );
  }
}

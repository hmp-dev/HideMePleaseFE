import 'package:equatable/equatable.dart';

import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';

class SpacesResponseEntity extends Equatable {
  final List<NearBySpaceEntity> spaces;
  final bool ambiguous;

  const SpacesResponseEntity({
    required this.spaces,
    required this.ambiguous,
  });

  @override
  List<Object?> get props => [spaces, ambiguous];

  SpacesResponseEntity.empty()
      : spaces = [],
        ambiguous = false;

  SpacesResponseEntity copyWith({
    List<NearBySpaceEntity>? spaces,
    bool? ambiguous,
  }) {
    return SpacesResponseEntity(
      spaces: spaces ?? this.spaces,
      ambiguous: ambiguous ?? this.ambiguous,
    );
  }
}

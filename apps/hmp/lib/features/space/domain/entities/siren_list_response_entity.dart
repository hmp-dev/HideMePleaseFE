import 'package:equatable/equatable.dart';
import 'package:mobile/features/space/domain/entities/siren_entity.dart';
import 'package:mobile/features/space/domain/entities/siren_pagination_entity.dart';

class SirenListResponseEntity extends Equatable {
  final List<SirenEntity> sirens;
  final SirenPaginationEntity? pagination;

  const SirenListResponseEntity({
    required this.sirens,
    this.pagination,
  });

  const SirenListResponseEntity.empty()
      : sirens = const [],
        pagination = null;

  @override
  List<Object?> get props => [sirens, pagination];
}

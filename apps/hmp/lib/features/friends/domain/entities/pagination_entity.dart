import 'package:equatable/equatable.dart';

class PaginationEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  const PaginationEntity.empty()
      : page = 1,
        limit = 20,
        total = 0,
        totalPages = 0;

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}

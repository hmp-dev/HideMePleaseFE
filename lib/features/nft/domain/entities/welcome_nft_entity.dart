import 'package:equatable/equatable.dart';

import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';

class WelcomeNftEntity extends Equatable {
  final int id;
  final String image;
  final int totalCount;
  final int usedCount;

  const WelcomeNftEntity({
    required this.id,
    required this.image,
    required this.totalCount,
    required this.usedCount,
  });

  @override
  List<Object?> get props => [
        id,
        image,
        totalCount,
        usedCount,
      ];

  const WelcomeNftEntity.empty()
      : id = 0,
        image = '',
        totalCount = 0,
        usedCount = 0;

  WelcomeNftEntity copyWith({
    int? id,
    String? image,
    int? totalCount,
    int? usedCount,
  }) {
    return WelcomeNftEntity(
      id: id ?? this.id,
      image: image ?? this.image,
      totalCount: totalCount ?? this.totalCount,
      usedCount: usedCount ?? this.usedCount,
    );
  }
}

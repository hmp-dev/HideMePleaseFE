import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';

final koreanNumFormat = NumberFormat("###,###,###", "en_US");

class WelcomeNftEntity extends Equatable {
  final String name;
  final String image;
  final int totalCount;
  final int usedCount;
  final String tokenAddress;

  const WelcomeNftEntity({
    required this.name,
    required this.image,
    required this.totalCount,
    required this.usedCount,
    required this.tokenAddress,
  });

  String get totalNfts => koreanNumFormat.format(totalCount);

  String get redeemedNfts => koreanNumFormat.format(usedCount);

  int get remainingCount => totalCount - usedCount;

  String get remainingNfts =>
      NumberFormat("###,###,### 남음", "en_US").format(remainingCount);

  @override
  List<Object?> get props => [
        name,
        image,
        totalCount,
        usedCount,
        tokenAddress,
      ];

  const WelcomeNftEntity.empty()
      : name = '',
        image = '',
        totalCount = 0,
        usedCount = 0,
        tokenAddress = '';

  WelcomeNftEntity copyWith({
    String? name,
    String? image,
    int? totalCount,
    int? usedCount,
    String? tokenAddress,
  }) {
    return WelcomeNftEntity(
      name: name ?? this.name,
      image: image ?? this.image,
      totalCount: totalCount ?? this.totalCount,
      usedCount: usedCount ?? this.usedCount,
      tokenAddress: tokenAddress ?? this.tokenAddress,
    );
  }
}

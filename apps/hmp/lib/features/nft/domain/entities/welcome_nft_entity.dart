import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

final koreanNumFormat = NumberFormat("###,###,###", "en_US");

class WelcomeNftEntity extends Equatable {
  final String name;
  final String tokenAddress;
  final String redeemTermsUrl;
  final int totalCount;
  final int usedCount;
  final String image;
  final bool freeNftAvailable;
  final String contractType;

  const WelcomeNftEntity({
    required this.name,
    required this.image,
    required this.totalCount,
    required this.usedCount,
    required this.tokenAddress,
    required this.redeemTermsUrl,
    required this.freeNftAvailable,
    required this.contractType,
  });

  String get totalNfts => koreanNumFormat.format(totalCount);

  String get redeemedNfts => koreanNumFormat.format(usedCount);

  int get remainingCount => totalCount - usedCount;

  String get remainingNfts =>
      NumberFormat("###,###,### ${LocaleKeys.remaining.tr()}", "en_US")
          .format(remainingCount);

  @override
  List<Object?> get props =>
      [name, image, totalCount, usedCount, tokenAddress, redeemTermsUrl, contractType];

  const WelcomeNftEntity.empty()
      : name = '',
        image = '',
        totalCount = 0,
        usedCount = 0,
        tokenAddress = '',
        redeemTermsUrl = '',
        freeNftAvailable = false,
        contractType = 'KIP-17';

  WelcomeNftEntity copyWith({
    String? name,
    String? image,
    int? totalCount,
    int? usedCount,
    String? tokenAddress,
    String? redeemTermsUrl,
    bool? freeNftAvailable,
    String? contractType,
  }) {
    return WelcomeNftEntity(
      name: name ?? this.name,
      image: image ?? this.image,
      totalCount: totalCount ?? this.totalCount,
      usedCount: usedCount ?? this.usedCount,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      redeemTermsUrl: redeemTermsUrl ?? this.redeemTermsUrl,
      freeNftAvailable: freeNftAvailable ?? this.freeNftAvailable,
      contractType: contractType ?? this.contractType,
    );
  }

  @override
  String toString() {
    return 'WelcomeNftEntity(name: $name, tokenAddress: $tokenAddress, redeemTermsUrl: $redeemTermsUrl, totalCount: $totalCount, usedCount: $usedCount, image: $image, freeNftAvailable: $freeNftAvailable, contractType: $contractType)';
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/load_more_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/widgets/space_benefits_item_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceBenefitListWidget extends StatefulWidget {
  const SpaceBenefitListWidget({
    super.key,
    required this.spaceDetailEntity,
  });

  final SpaceDetailEntity spaceDetailEntity;

  @override
  State<SpaceBenefitListWidget> createState() => _SpaceBenefitListWidgetState();
}

class _SpaceBenefitListWidgetState extends State<SpaceBenefitListWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        if (state.benefitsGroupEntity.benefits.isEmpty) {
          return Column(
            children: [
              Text(LocaleKeys.memberShipBenefits.tr(),
                  style: fontTitle06Medium()),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  DefaultImage(
                    path: "assets/icons/ic_tick_badge.svg",
                    width: 20,
                    height: 20,
                  ),
                  const HorizontalSpace(8),
                  Text(
                    LocaleKeys.benefitInfo.tr(),
                    style: fontTitle06Medium(),
                  ),
                  const HorizontalSpace(8),
                  Text(
                    "${state.benefitsGroupEntity.benefitCount}",
                    style: fontTitle07(color: fore2),
                  )
                ],
              ),
              const VerticalSpace(20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.benefitsGroupEntity.benefits.length,
                itemBuilder: (context, index) {
                  return SpaceBenefitItemWidget(
                    spaceDetailEntity: widget.spaceDetailEntity,
                    isShowImage: false,
                    nftBenefitEntity: state.benefitsGroupEntity.benefits[index],
                  );
                },
              ),
              if (state.benefitsGroupEntity.benefits.length !=
                  state.benefitsGroupEntity.benefitCount)
                LoadMoreIconButton(
                  onTap: () {
                    getIt<SpaceCubit>().onGetSpaceBenefits(
                      spaceId: state.benefitsGroupEntity.benefits[0].spaceId,
                      isLoadingMore: true,
                      nextCursor: state.benefitsGroupEntity.next,
                    );
                  },
                ),
            ],
          );
        }
      },
    );
  }

  void getSpacesDataToNavigateToRedeemBenefitScreen(String tokenAddress) {
    final locationState = getIt<EnableLocationCubit>().state;

    if (locationState.latitude == 0.0 || locationState.longitude == 0.0) {
      getIt<EnableLocationCubit>().onAskDeviceLocation();
    } else {
      //TODO change the hard coded latitude with the device location
      getIt<SpaceCubit>().onGetSpacesData(
        tokenAddress: tokenAddress,
        latitude: 2.0, //locationState.latitude,
        longitude: 2.0, //locationState.longitude,
      );
    }

    Log.trace("latitude: ${locationState.latitude}");
    Log.trace("longitude: ${locationState.longitude}");
  }
}

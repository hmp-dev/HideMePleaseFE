import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_available_text.dart';
import 'package:mobile/features/home/presentation/widgets/benefit_used_text.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class HomeBenefitItemWidget extends StatelessWidget {
  const HomeBenefitItemWidget({
    super.key,
    required this.nftBenefitEntity,
    this.isShowImage = true,
  });

  final BenefitEntity nftBenefitEntity;
  final bool isShowImage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpaceCubit, SpaceState>(
      bloc: getIt<SpaceCubit>(),
      listener: (context, state) {
        // if (state.submitStatus == RequestStatus.success) {
        //   RedeemBenefitScreenWithBenefitId.push(
        //       context, nftBenefitEntity, state.spaceDetailEntity);
        // }
      },
      child: Column(
        children: [
          Row(
            children: [
              if (isShowImage)
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: CustomImageView(
                    url: nftBenefitEntity.spaceImage,
                    width: 54,
                    height: 54,
                    radius: BorderRadius.circular(2),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nftBenefitEntity.description,
                      style: fontCompactMdMedium()),
                  const VerticalSpace(5),
                  Text(nftBenefitEntity.spaceName,
                      style: fontCompactSm(color: fore3)),
                ],
              ),
              const Spacer(),
              nftBenefitEntity.used
                  ? const BenefitUsedText()
                  : BlocConsumer<EnableLocationCubit, EnableLocationState>(
                      bloc: getIt<EnableLocationCubit>()
                        ..checkLocationEnabled(),
                      listener: (context, state) {},
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () {
                            if (!state.isLocationDenied) {
                              // call the Space Detail and om Success Navigate to Redeem Benefit Screen

                              // getIt<SpaceCubit>().onGetSpaceDetail(
                              //     spaceId: nftBenefitEntity.spaceId);
                            } else {
                              // open Alert Dialogue to Show Info and Ask to enable Location
                              showEnableLocationAlertDialog(
                                context: context,
                                title:
                                    LocaleKeys.enableLocationAlertMessage.tr(),
                                onConfirm: () {
                                  getIt<EnableLocationCubit>()
                                      .onAskDeviceLocationWithOpenSettings();
                                },
                                onCancel: () {},
                              );
                            }

                            "latitude: ${state.latitude}".log();
                            "longitude: ${state.longitude}".log();
                          },
                          child: const BenefitAvailableText(),
                        );
                      },
                    ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: fore5),
          )
        ],
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/helpers/glassmorphism_widgets/glass_container.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/circle_dot_widget.dart';
import 'package:mobile/features/home/presentation/widgets/dashed_divider.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/presentation/widgets/benefit_title_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BenefitCardWidgetWithSpaceDetailEntity extends StatelessWidget {
  const BenefitCardWidgetWithSpaceDetailEntity({
    super.key,
    required this.space,
    required this.nftBenefitEntity,
    this.isBenefitRedeemSuccess,
    required this.isMatchedSpaceFound,
  });

  final SpaceDetailEntity space;
  final BenefitEntity nftBenefitEntity;
  final bool? isBenefitRedeemSuccess;
  final bool isMatchedSpaceFound;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: SizedBox(
        width: 303,
        height: 436,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 293,
              height: 436,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: nftBenefitEntity.nftCollectionImage == ""
                    ? const DecorationImage(
                        image:
                            AssetImage("assets/images/place_holder_card.png"),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image:
                            NetworkImage(nftBenefitEntity.nftCollectionImage),
                        fit: BoxFit.cover,
                      ),
              ),
              child: GlassContainer(
                blur: 30.0,
                width: 293,
                height: 436,
                radius: 8,
                child: Container(
                  width: 293,
                  height: 436,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: fore4),
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BenefitTitleWidget(nftBenefitEntity: nftBenefitEntity),
                        const VerticalSpace(10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 10),
                            child: DefaultImage(
                              path: "assets/icons/ic_tick_badge.svg",
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                         Text(
                          nftBenefitEntity.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: fontTitle04(),
                        ),
                        const Spacer(),
                        if (!nftBenefitEntity.singleUse)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                DefaultImage(
                                  path: "assets/icons/ic_info_icon.svg",
                                  width: 16,
                                  height: 16,
                                  color: fore2,
                                ),
                                const HorizontalSpace(5),
                                Text(
                                  "무료 혜택은 각 제휴 공간에서 1개 사용가능",
                                  style: fontCompactXs(color: fore2),
                                )
                              ],
                            ),
                          ),
                        const VerticalSpace(10),
                        const DashedDivider(),
                        const VerticalSpace(20),
                        isBenefitRedeemSuccess != null &&
                                isBenefitRedeemSuccess == true
                            ? Center(
                                child: Text(
                                  LocaleKeys.used.tr(),
                                  style: fontCompactMd(),
                                ),
                              )
                            : isMatchedSpaceFound
                                ? Center(
                                    child: Text(
                                      getStateString(nftBenefitEntity.state),
                                      style: fontCompactMd(),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      LocaleKeys.unavailable.tr(),
                                      style: fontCompactMd(),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 50,
              left: -4.5,
              child: CircleDotWidget(
                side: BorderSideVal.left,
              ),
            ),
            const Positioned(
              bottom: 50,
              right: -4.5,
              child: CircleDotWidget(
                side: BorderSideVal.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getStateString(String state) {
    switch (state) {
      case 'available':
        return LocaleKeys.available.tr();
      case 'unavailable':
        return LocaleKeys.unavailable.tr();
      case 'used':
        return LocaleKeys.used.tr();
      default:
        return '';
    }
  }
}

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/util/ui_util.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/space_select_item.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';
import 'package:mobile/features/space/presentation/screens/redeem_benefit_screen.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SpaceSelectionScreen extends StatelessWidget {
  // Constructor to initialize the list of spaces
  const SpaceSelectionScreen({
    super.key,
    required this.spaces,
  });

  // List of NearBySpaceEntity representing the spaces to display
  final List<NearBySpaceEntity> spaces;

  // Method to display the SpaceSelectionScreen in a modal bottom sheet
  static Future<dynamic> show(
      BuildContext context, List<NearBySpaceEntity> spaces) async {
    await showModalBottomSheet(
        useSafeArea: false,
        isScrollControlled: true,
        context: context,
        builder: (_) => SpaceSelectionScreen(spaces: spaces));
  }

  // Build method to create the widget tree
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      // Apply a blur filter to the background of the widget
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.only(
          top: 30,
          left: 20,
          right: 20,
          bottom: UiUtil.bottomPadding(context),
        ),
        decoration: const BoxDecoration(
          color: scaffoldBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Display the title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.spaceSettings.tr(),
                  style: fontTitle05Medium(),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: DefaultImage(
                    path: 'assets/icons/ic_close.svg',
                    width: 32,
                    height: 32,
                    color: white,
                  ),
                ),
              ],
            ),
            const VerticalSpace(30),
            // Display the text explaining the purpose of the screen
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.chooseSpace.tr(),
                  style: fontBodyMd(),
                ),
                const HorizontalSpace(10),
                Text(
                  LocaleKeys.withIn10MeterFromCurrentLocation.tr(),
                  style: fontBodyXs(color: fore2),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Display the list of spaces
            spaces.isEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9 - 200,
                    child: Center(
                      child: CustomImageView(
                        svgPath: "assets/images/hmp_eyes_up.svg",
                        width: 60,
                        height: 60,
                      ),
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9 - 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: spaces.length,
                      itemBuilder: (context, index) {
                        // Build each SpaceSelectItem widget
                        return SpaceSelectItem(
                          spaceEntity: spaces[index],
                          onTap: () {
                            Navigator.pop(context);
                            RedeemBenefitScreen.push(
                              context,
                              nearBySpaceEntity: spaces[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

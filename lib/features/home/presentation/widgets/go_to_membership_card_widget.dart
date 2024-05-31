import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_rounded_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/edit_membership_list.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class GoToMemberShipCardWidget extends StatelessWidget {
  const GoToMemberShipCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 326,
          height: 486,
          decoration: BoxDecoration(
            color: bg1,
            borderRadius: BorderRadius.circular(4),
            image: const DecorationImage(
              image: AssetImage("assets/images/empty-card-bg.png"),
              fit: BoxFit.fill,
            ),
            border: Border.all(
              color: fore3,
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 322,
              height: 482,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: fore3,
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 316,
                  height: 476,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: black100,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 486,
          width: 326,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DefaultImage(
                path: "assets/images/memebership-list-image.png",
                width: 102,
                height: 85,
                boxFit: BoxFit.cover,
              ),
              const VerticalSpace(40),
              CustomRoundedButton(
                title: LocaleKeys.editMembershipList.tr(),
                onTap: () {
                  EditMembershipListScreen.push(context, true);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

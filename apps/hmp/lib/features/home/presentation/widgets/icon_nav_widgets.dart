import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/home/presentation/widgets/feature_icon_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class IconNavWidgets extends StatelessWidget {
  const IconNavWidgets({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  final int selectedIndex;
  final Function(int) onIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FeatureIconWidget(
            title: LocaleKeys.benefits.tr(),
            imagePath: selectedIndex == 0
                ? "assets/icons/ic_benefits_hmp.svg"
                : "assets/icons/ic_benefits_dark.svg",
            titleColor: selectedIndex == 0 ? white : fore3,
            onTap: () => onIndexChanged(0),
          ),
          // FeatureIconWidget(
          //   title: LocaleKeys.event.tr(),
          //   imagePath: selectedIndex == 1
          //       ? "assets/icons/ic_event_hmp.svg"
          //       : "assets/icons/ic_events_dark.svg",
          //   titleColor: selectedIndex == 1 ? white : fore3,
          //   onTap: () => onIndexChanged(1),
          // ),
          //250429 remove 멤버
          // FeatureIconWidget(
          //   title: LocaleKeys.member.tr(),
          //   imagePath: selectedIndex == 2
          //       ? "assets/icons/ic_member_hmp.svg"
          //       : "assets/icons/ic_member_dark.svg",
          //   titleColor: selectedIndex == 2 ? white : fore3,
          //   onTap: () => onIndexChanged(2),
          // ),
          // FeatureIconWidget(
          //   title: LocaleKeys.chatting.tr(),
          //   imagePath: selectedIndex == 3
          //       ? "assets/icons/ic_chat_hmp.svg"
          //       : "assets/icons/ic_chat_dark.svg",
          //   titleColor: selectedIndex == 3 ? white : fore3,
          //   onTap: () => onIndexChanged(3),
          // ),
        ],
      ),
    );
  }
}

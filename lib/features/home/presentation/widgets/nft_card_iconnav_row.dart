import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/presentation/widgets/feature_icon_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class NftCardIconNavRow extends StatelessWidget {
  const NftCardIconNavRow({
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
            imagePath: "assets/icons/ic_benefits.svg",
            onTap: () => onIndexChanged(0),
          ),
          FeatureIconWidget(
            title: LocaleKeys.event.tr(),
            imagePath: "assets/icons/ic_events.svg",
            onTap: () => onIndexChanged(1),
          ),
          FeatureIconWidget(
            title: LocaleKeys.member.tr(),
            imagePath: "assets/icons/ic_member.svg",
            onTap: () => onIndexChanged(2),
          ),
          FeatureIconWidget(
            title: LocaleKeys.chatting.tr(),
            imagePath: "assets/icons/ic_chatting.svg",
            onTap: () => onIndexChanged(3),
          ),
        ],
      ),
    );
  }
}

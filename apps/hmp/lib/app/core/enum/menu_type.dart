import 'package:flutter/cupertino.dart';

enum MenuType {
  space(
    activeIconPath: "assets/icons/ic_space_enabled.svg",
    deactivateIconPath: "assets/icons/ic_space_disabled.svg",
    menuIndex: 0,
  ),
  events(
    activeIconPath: "assets/icons/ic_wallet_enabled.svg",
    deactivateIconPath: "assets/icons/ic_wallet_disabled.svg",
    menuIndex: 1,
  ),
  home(
    activeIconPath: "assets/icons/home_icon_active.png",
    deactivateIconPath: "assets/icons/home_icon_disabled.png",
    menuIndex: 2,
  ),
  community(
    activeIconPath: "assets/icons/ic_community_enabled_jayden.svg",
    deactivateIconPath: "assets/icons/ic_community_disabled_jayden.svg",
    menuIndex: 3,
  ),
  settings(
    activeIconPath: "assets/icons/ic_more_enabled.svg",
    deactivateIconPath: "assets/icons/ic_more_disabled.svg",
    menuIndex: 4,
  );

  const MenuType({
    required this.deactivateIconPath,
    required this.activeIconPath,
    required this.menuIndex,
  });

  final String deactivateIconPath;
  final String activeIconPath;
  final int menuIndex;

  String title(BuildContext context) {
    switch (this) {
      case MenuType.space:
        return "Space";
      case MenuType.events:
        return "Events";
      case MenuType.home:
        return "Home";
      case MenuType.community:
        return "Community";
      case MenuType.settings:
        return "Settings";
    }
  }
}

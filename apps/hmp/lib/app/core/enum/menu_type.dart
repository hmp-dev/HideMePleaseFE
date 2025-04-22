import 'package:flutter/cupertino.dart';

enum MenuType {
  space(
    activeIconPath: "assets/icons/nav_space_active.png",
    deactivateIconPath: "assets/icons/nav_space_deactive.png",
    menuIndex: 0,
  ),
  events(
    activeIconPath: "assets/icons/nav_wallet_active.png",
    deactivateIconPath: "assets/icons/nav_wallet_deactive.png",
    menuIndex: 1,
  ),
  home(
    activeIconPath: "assets/icons/nav_home_active.png",
    deactivateIconPath: "assets/icons/nav_home_deactive.png",
    menuIndex: 2,
  ),
  /*community(
    activeIconPath: "assets/icons/ic_community_enabled_jayden.svg",
    deactivateIconPath: "assets/icons/ic_community_disabled_jayden.svg",
    menuIndex: 3,
  ),*/
  settings(
    activeIconPath: "assets/icons/nav_more_active.png",
    deactivateIconPath: "assets/icons/nav_more_deactive.png",
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
      //case MenuType.community:
      //  return "Community";
      case MenuType.settings:
        return "Settings";
    }
  }
}

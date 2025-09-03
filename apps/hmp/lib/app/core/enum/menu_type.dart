import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

enum MenuType {
  home(
    activeIconPath: "assets/icons/nav_home_active.png",
    deactivateIconPath: "assets/icons/nav_home_deactive.png",
    menuIndex: 0,
  ),
  space(
    activeIconPath: "assets/icons/nav_space_active.png",
    deactivateIconPath: "assets/icons/nav_space_deactive.png",
    menuIndex: 1,
  ),
  events(
    activeIconPath: "assets/icons/nav_wallet_active.png",
    deactivateIconPath: "assets/icons/nav_wallet_deactive.png",
    menuIndex: 2,
  ),
  /*community(
    activeIconPath: "assets/icons/ic_community_enabled_jayden.svg",
    deactivateIconPath: "assets/icons/ic_community_disabled_jayden.svg",
    menuIndex: 3,
  ),*/
  myProfile(
    activeIconPath: "assets/icons/nav_more_active.png",
    deactivateIconPath: "assets/icons/nav_more_deactive.png",
    menuIndex: 3,
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
      case MenuType.home:
        return LocaleKeys.nav_home.tr();
      case MenuType.space:
        return LocaleKeys.nav_hiding.tr();
      case MenuType.events:
        return "Events";
      //case MenuType.community:
      //  return "Community";
      case MenuType.myProfile:
        return "My";
    }
  }
}

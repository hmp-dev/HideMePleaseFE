// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class SBUSelectableUserListItemComponent extends SBUStatefulComponent {
  final double width;
  final double height;
  final Color backgroundColor;
  final bool isChecked;
  final User user;
  final void Function(bool isChecked, User user) onListItemCheckChanged;

  const SBUSelectableUserListItemComponent({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.isChecked,
    required this.user,
    required this.onListItemCheckChanged,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUUserListItemComponentState();
}

class SBUUserListItemComponentState
    extends State<SBUSelectableUserListItemComponent> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final width = widget.width;
    final height = widget.height;
    final backgroundColor = widget.backgroundColor;
    _isChecked = widget.isChecked;
    final user = widget.user;
    final onListItemCheckChanged = widget.onListItemCheckChanged;

    final item = Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                _isChecked = !_isChecked;
              });
            }
            onListItemCheckChanged(_isChecked, user);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: widget.getAvatarComponent(
                  isLightTheme: isLightTheme,
                  size: 36,
                  user: user,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: SBUTextComponent(
                                  text: widget.getNickname(user, strings),
                                  textType: SBUTextType.subtitle2,
                                  textColorType: SBUTextColorType.text01,
                                ),
                              ),
                            ),
                            _isChecked
                                ? Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SBUIconComponent(
                                      iconSize: 24,
                                      iconData: SBUIcons.checkboxOn,
                                      iconColor: isLightTheme
                                          ? SBUColors.primaryMain
                                          : SBUColors.primaryLight,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SBUIconComponent(
                                      iconSize: 24,
                                      iconData: SBUIcons.checkboxOff,
                                      iconColor: isLightTheme
                                          ? SBUColors.lightThemeTextLowEmphasis
                                          : SBUColors.darkThemeTextLowEmphasis,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isLightTheme
                          ? SBUColors.lightThemeTextDisabled
                          : SBUColors.darkThemeTextDisabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return item;
  }
}

// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_avatar_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_badge_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_file_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/public/resource/sbu_theme_provider.dart';
import 'package:sendbird_uikit/src/public/resource/sbu_colors.dart';

class SBUChannelListItemComponent extends SBUStatefulComponent {
  final double width;
  final double height;
  final Color backgroundColor;
  final BaseChannel channel;
  final SBUAvatarComponent avatar;
  final SBUTextComponent title;
  final SBUTextComponent date;
  final SBUTextComponent lastMessage;
  final SBUIconComponent? preTitleIcon;
  final SBUTextComponent? userCount;
  final SBUIconComponent? postTitleIcon;
  final SBUIconComponent? postTitleIcon2;
  final SBUIconComponent? preDateIcon;
  final SBUFileIconComponent? fileIcon;
  final SBUBadgeComponent? badge;
  final void Function(BaseChannel)? onListItemClicked;
  final void Function(BaseChannel)? onListItemLongPressed;

  const SBUChannelListItemComponent({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.channel,
    required this.avatar,
    required this.title,
    required this.date,
    required this.lastMessage,
    this.preTitleIcon,
    this.userCount,
    this.postTitleIcon,
    this.postTitleIcon2,
    this.preDateIcon,
    this.fileIcon,
    this.badge,
    this.onListItemClicked,
    this.onListItemLongPressed,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUChannelListItemComponentState();
}

class SBUChannelListItemComponentState
    extends State<SBUChannelListItemComponent> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();

    final width = widget.width;
    final height = widget.height;
    final backgroundColor = widget.backgroundColor;
    final channel = widget.channel;
    final avatar = widget.avatar;
    final title = widget.title;
    final date = widget.date;
    final lastMessage = widget.lastMessage;
    final preTitleIcon = widget.preTitleIcon;
    final userCount = widget.userCount;
    final postTitleIcon = widget.postTitleIcon;
    final postTitleIcon2 = widget.postTitleIcon2;
    final preDateIcon = widget.preDateIcon;
    final fileIcon = widget.fileIcon;
    final badge = widget.badge;
    final onListItemClicked = widget.onListItemClicked;
    final onListItemLongPressed = widget.onListItemLongPressed;

    final item = Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onListItemClicked != null) {
              onListItemClicked(channel);
            }
          },
          onLongPress: () {
            if (onListItemLongPressed != null) {
              onListItemLongPressed(channel);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: avatar,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (preTitleIcon != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: preTitleIcon,
                                        ),
                                      Flexible(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4),
                                          child: title,
                                        ),
                                      ),
                                      userCount != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                top: 1, // Check
                                                right: 4,
                                              ),
                                              child: userCount,
                                            )
                                          : Container(),
                                      postTitleIcon != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: postTitleIcon,
                                            )
                                          : Container(),
                                      postTitleIcon2 != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: postTitleIcon2,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 3, // Check
                                  ),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        preDateIcon != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: preDateIcon,
                                              )
                                            : Container(),
                                        date,
                                      ]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (fileIcon != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: fileIcon,
                                  ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: lastMessage,
                                  ),
                                ),
                                if (badge != null) badge,
                              ],
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

// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelModerationsScreen
class SBUGroupChannelModerationsScreen extends SBUStatefulComponent {
  final int messageCollectionNo;
  final void Function(GroupChannel)? onOperatorsButtonClicked;
  final void Function(GroupChannel)? onMutedMembersButtonClicked;
  final void Function(GroupChannel)? onBannedUsersButtonClicked;

  const SBUGroupChannelModerationsScreen({
    required this.messageCollectionNo,
    this.onOperatorsButtonClicked,
    this.onMutedMembersButtonClicked,
    this.onBannedUsersButtonClicked,
    super.key,
  });

  @override
  State<StatefulWidget> createState() =>
      SBUGroupChannelModerationsScreenState();
}

class SBUGroupChannelModerationsScreenState
    extends State<SBUGroupChannelModerationsScreen> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final channel = context
        .watch<SBUMessageCollectionProvider>()
        .getCollection(widget.messageCollectionNo)
        ?.channel;

    bool isFrozenChannel = (channel != null && channel.isFrozen);

    final header = SBUHeaderComponent(
      width: double.maxFinite,
      height: 56,
      backgroundColor:
          isLightTheme ? SBUColors.background50 : SBUColors.background500,
      title: SBUTextComponent(
        text: strings.moderations,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: true,
    );

    final freezeChannelSwitch = Switch(
      value: isFrozenChannel,
      onChanged: (value) async {
        runZonedGuarded(() async {
          if (value) {
            await channel?.freeze();
          } else {
            await channel?.unfreeze();
          }

          setState(() {
            isFrozenChannel = value;
          });
        }, (error, stack) {
          // TODO: Check error
        });
      },
      activeColor: SBUColors.primaryMain,
      activeTrackColor: SBUColors.primaryLight,
      inactiveThumbColor: SBUColors.background200,
      inactiveTrackColor: SBUColors.background300,
    );

    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: isLightTheme ? SBUColors.background50 : SBUColors.background600,
      child: Column(
        children: [
          header,
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                color: isLightTheme
                    ? SBUColors.background50
                    : SBUColors.background600,
                child: channel != null
                    ? Column(
                        children: [
                          if (widget.onOperatorsButtonClicked != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (widget.onOperatorsButtonClicked != null) {
                                    widget.onOperatorsButtonClicked!(channel);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 16, right: 16, bottom: 15),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.operator,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.operators,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.chevronRight,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .lightThemeTextHighEmphasis
                                              : SBUColors
                                                  .darkThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onOperatorsButtonClicked != null)
                            _line(isLightTheme),
                          if (widget.onMutedMembersButtonClicked != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (widget.onMutedMembersButtonClicked !=
                                      null) {
                                    widget
                                        .onMutedMembersButtonClicked!(channel);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 16, right: 16, bottom: 15),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.mute,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.mutedMembers,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.chevronRight,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .lightThemeTextHighEmphasis
                                              : SBUColors
                                                  .darkThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onMutedMembersButtonClicked != null)
                            _line(isLightTheme),
                          if (widget.onBannedUsersButtonClicked != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (widget.onBannedUsersButtonClicked !=
                                      null) {
                                    widget.onBannedUsersButtonClicked!(channel);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 16, right: 16, bottom: 15),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.ban,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.bannedUsers,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SBUIconComponent(
                                          iconSize: 24,
                                          iconData: SBUIcons.chevronRight,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .lightThemeTextHighEmphasis
                                              : SBUColors
                                                  .darkThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onBannedUsersButtonClicked != null)
                            _line(isLightTheme),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                freezeChannelSwitch
                                    .onChanged!(!freezeChannelSwitch.value);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 16, right: 16, bottom: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: SBUIconComponent(
                                        iconSize: 24,
                                        iconData: SBUIcons.freeze,
                                        iconColor: isLightTheme
                                            ? SBUColors.primaryMain
                                            : SBUColors.primaryLight,
                                      ),
                                    ),
                                    Expanded(
                                      child: SBUTextComponent(
                                        text: strings.freezeChannel,
                                        textType: SBUTextType.subtitle2,
                                        textColorType: SBUTextColorType.text01,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: SizedBox(
                                        height: 24,
                                        child: freezeChannelSwitch,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _line(isLightTheme),
                        ],
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(bool isLightTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        height: 1,
        color: isLightTheme
            ? SBUColors.lightThemeTextDisabled
            : SBUColors.darkThemeTextDisabled,
      ),
    );
  }
}

// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_menu_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_dialog_input_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_dialog_menu_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_button_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelInformationScreen
class SBUGroupChannelInformationScreen extends SBUStatefulComponent {
  final int messageCollectionNo;
  final void Function(GroupChannel)? onChannelLeft;
  final void Function(GroupChannel)? onModerationsButtonClicked;
  final void Function(GroupChannel)? onMembersButtonClicked;

  const SBUGroupChannelInformationScreen({
    required this.messageCollectionNo,
    this.onChannelLeft,
    this.onModerationsButtonClicked,
    this.onMembersButtonClicked,
    super.key,
  });

  @override
  State<StatefulWidget> createState() =>
      SBUGroupChannelInformationScreenState();
}

class SBUGroupChannelInformationScreenState
    extends State<SBUGroupChannelInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final channel = context
        .watch<SBUMessageCollectionProvider>()
        .getCollection(widget.messageCollectionNo)
        ?.channel;

    bool isNotificationsOn = (channel != null &&
        channel.myPushTriggerOption != GroupChannelPushTriggerOption.off);

    final myMember = widget.getMyMember(channel);
    final amIOperator = myMember?.role == Role.operator;

    final header = SBUHeaderComponent(
      width: double.maxFinite,
      height: 56,
      backgroundColor:
          isLightTheme ? SBUColors.background50 : SBUColors.background500,
      title: SBUTextComponent(
        text: strings.channelInformation,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: true,
      textButton: SBUTextButtonComponent(
        height: 32,
        text: SBUTextComponent(
          text: strings.edit,
          textType: SBUTextType.button,
          textColorType: SBUTextColorType.primary,
        ),
        onButtonClicked: () async {
          await showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            builder: (context) {
              return SBUBottomSheetMenuComponent(
                buttonNames: [
                  strings.changeChannelName,
                  if (widget.canGetPhotoFile()) strings.changeChannelImage,
                ],
                onButtonClicked: (buttonName) async {
                  if (buttonName == strings.changeChannelName) {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => SBUDialogInputComponent(
                        title: strings.changeChannelName,
                        initialText: channel?.name,
                        onCancelButtonClicked: () {
                          // Cancel
                        },
                        onSaveButtonClicked: (enteredText) async {
                          runZonedGuarded(() async {
                            await channel?.updateChannel(
                              GroupChannelUpdateParams()..name = enteredText,
                            );
                          }, (error, stack) {
                            // TODO: Check error
                          });
                        },
                      ),
                    );
                  } else if (buttonName == strings.changeChannelImage) {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => SBUDialogMenuComponent(
                        title: strings.changeChannelImage,
                        buttonNames: [
                          if (widget.canTakePhoto()) strings.takePhoto,
                          if (widget.canChoosePhoto()) strings.choosePhoto,
                        ],
                        onButtonClicked: (buttonName) async {
                          FileInfo? fileInfo;
                          if (buttonName == strings.takePhoto) {
                            fileInfo = await SendbirdUIKit().takePhoto!();
                          } else if (buttonName == strings.choosePhoto) {
                            fileInfo = await SendbirdUIKit().choosePhoto!();
                          }

                          if (fileInfo != null && channel != null) {
                            runZonedGuarded(() async {
                              await channel.updateChannel(
                                  GroupChannelUpdateParams()
                                    ..coverImage = fileInfo);
                            }, (error, stack) {
                              // TODO: Check error
                            });
                          }
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        padding: const EdgeInsets.all(8),
      ),
    );

    final notificationsSwitch = Switch(
      value: isNotificationsOn,
      onChanged: (value) async {
        runZonedGuarded(() async {
          await channel?.setMyPushTriggerOption(value
              ? GroupChannelPushTriggerOption.all
              : GroupChannelPushTriggerOption.off);

          setState(() {
            isNotificationsOn = (channel?.myPushTriggerOption !=
                GroupChannelPushTriggerOption.off);
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
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 12),
                            child: widget.getGroupChannelAvatarComponent(
                              isLightTheme: isLightTheme,
                              size: 80,
                              channel: channel,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 23),
                            child: SBUTextComponent(
                              text:
                                  widget.getGroupChannelName(channel, strings),
                              textType: SBUTextType.heading1,
                              textColorType: SBUTextColorType.text01,
                            ),
                          ),
                          _line(isLightTheme),
                          if (amIOperator &&
                              widget.onModerationsButtonClicked != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (widget.onModerationsButtonClicked !=
                                      null) {
                                    widget.onModerationsButtonClicked!(channel);
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
                                          iconData: SBUIcons.moderations,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.moderations,
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
                          if (amIOperator &&
                              widget.onModerationsButtonClicked != null)
                            _line(isLightTheme),
                          if (!kIsWeb)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  notificationsSwitch
                                      .onChanged!(!notificationsSwitch.value);
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
                                          iconData: SBUIcons.notifications,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.notifications,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SizedBox(
                                          height: 24,
                                          child: notificationsSwitch,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (!kIsWeb) _line(isLightTheme),
                          if (widget.onMembersButtonClicked != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (widget.onMembersButtonClicked != null) {
                                    widget.onMembersButtonClicked!(channel);
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
                                          iconData: SBUIcons.members,
                                          iconColor: isLightTheme
                                              ? SBUColors.primaryMain
                                              : SBUColors.primaryLight,
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.members,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SBUTextComponent(
                                          text:
                                              channel.members.length.toString(),
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text02,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
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
                          if (widget.onMembersButtonClicked != null)
                            _line(isLightTheme),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                runZonedGuarded(() {
                                  channel.leave().then((value) {
                                    if (widget.onChannelLeft != null) {
                                      widget.onChannelLeft!(channel);
                                    }
                                  });
                                }, (error, stack) {
                                  // TODO: Check error
                                });
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
                                        iconData: SBUIcons.leave,
                                        iconColor: isLightTheme
                                            ? SBUColors.errorMain
                                            : SBUColors.errorLight,
                                      ),
                                    ),
                                    Expanded(
                                      child: SBUTextComponent(
                                        text: strings.leaveChannel,
                                        textType: SBUTextType.subtitle2,
                                        textColorType: SBUTextColorType.text01,
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

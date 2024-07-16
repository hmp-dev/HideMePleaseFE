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
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';
import 'package:sendbird_uikit/src/internal/utils/sbu_preferences.dart';

/// SBUGroupChannelSettingsScreen
class SBUGroupChannelSettingsScreen extends SBUStatefulComponent {
  final Future<bool> Function(bool isPushNotificationsOn)? setPushNotifications;
  final void Function(String nickname)? onNicknameChanged;

  const SBUGroupChannelSettingsScreen({
    this.setPushNotifications,
    this.onNicknameChanged,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUGroupChannelSettingsScreenState();
}

class SBUGroupChannelSettingsScreenState
    extends State<SBUGroupChannelSettingsScreen> {
  bool isPushNotificationsOn = SBUPreferences().getPushNotifications();
  bool isDoNotDisturbOn = SBUPreferences().getDoNotDisturb();

  @override
  void initState() {
    super.initState();

    runZonedGuarded(() {
      SendbirdChat.getDoNotDisturb().then((value) async {
        await SBUPreferences().setDoNotDisturb(value.isDoNotDisturbOn);
        if (mounted) {
          setState(() {
            isDoNotDisturbOn = value.isDoNotDisturbOn;
          });
        }
      });
    }, (error, stack) {
      // TODO: Check error
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final currentUser = SendbirdChat.currentUser;

    final header = SBUHeaderComponent(
      width: double.maxFinite,
      height: 56,
      backgroundColor:
          isLightTheme ? SBUColors.background50 : SBUColors.background500,
      title: SBUTextComponent(
        text: strings.settings,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: false,
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
                  strings.changeNickname,
                  if (widget.canGetPhotoFile()) strings.changeProfileImage,
                ],
                onButtonClicked: (buttonName) async {
                  if (buttonName == strings.changeNickname) {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => SBUDialogInputComponent(
                        title: strings.changeNickname,
                        initialText: currentUser?.nickname,
                        onCancelButtonClicked: () {
                          // Cancel
                        },
                        onSaveButtonClicked: (enteredText) async {
                          runZonedGuarded(() async {
                            await SendbirdChat.updateCurrentUserInfo(
                              nickname: enteredText,
                            );

                            if (widget.onNicknameChanged != null) {
                              widget.onNicknameChanged!(enteredText);
                            }

                            if (mounted) {
                              setState(() {});
                            }
                          }, (error, stack) {
                            // TODO: Check error
                          });
                        },
                      ),
                    );
                  } else if (buttonName == strings.changeProfileImage) {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => SBUDialogMenuComponent(
                        title: strings.changeProfileImage,
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

                          if (fileInfo != null) {
                            runZonedGuarded(() async {
                              await SendbirdChat.updateCurrentUserInfo(
                                  profileFileInfo: fileInfo);

                              if (mounted) {
                                setState(() {});
                              }
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

    final darkThemeSwitch = Switch(
      value: !isLightTheme,
      onChanged: (value) async {
        await SBUThemeProvider()
            .setTheme(value ? SBUTheme.dark : SBUTheme.light);
      },
      activeColor: SBUColors.primaryMain,
      activeTrackColor: SBUColors.primaryLight,
      inactiveThumbColor: SBUColors.background200,
      inactiveTrackColor: SBUColors.background300,
    );

    final pushNotificationsSwitch = Switch(
      value: isPushNotificationsOn,
      onChanged: (value) async {
        if (widget.setPushNotifications != null) {
          runZonedGuarded(() async {
            if (await widget.setPushNotifications!(value)) {
              await SBUPreferences().setPushNotifications(value);

              if (mounted) {
                setState(() {
                  isPushNotificationsOn = value;
                });
              }
            }
          }, (error, stack) {
            // TODO: Check error
          });
        }
      },
      activeColor: SBUColors.primaryMain,
      activeTrackColor: SBUColors.primaryLight,
      inactiveThumbColor: SBUColors.background200,
      inactiveTrackColor: SBUColors.background300,
    );

    final doNotDisturbSwitch = Switch(
      value: isDoNotDisturbOn,
      onChanged: (value) async {
        runZonedGuarded(() async {
          await SendbirdChat.setDoNotDisturb(enable: value);
          await SBUPreferences().setDoNotDisturb(value);

          if (mounted) {
            setState(() {
              isDoNotDisturbOn = value;
            });
          }
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
                child: currentUser != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 12),
                            child: Center(
                              child: widget.getAvatarComponent(
                                isLightTheme: isLightTheme,
                                size: 80,
                                user: currentUser,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 23),
                            child: Center(
                              child: SBUTextComponent(
                                text: widget.getNickname(currentUser, strings),
                                textType: SBUTextType.heading1,
                                textColorType: SBUTextColorType.text01,
                              ),
                            ),
                          ),
                          _line(isLightTheme),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, top: 16, right: 16, bottom: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SBUTextComponent(
                                  text: strings.userId,
                                  textType: SBUTextType.body2,
                                  textColorType: SBUTextColorType.text02,
                                ),
                                const SizedBox(height: 4),
                                SBUTextComponent(
                                  text: currentUser.userId,
                                  textType: SBUTextType.body3,
                                  textColorType: SBUTextColorType.text01,
                                ),
                              ],
                            ),
                          ),
                          _line(isLightTheme),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                darkThemeSwitch
                                    .onChanged!(!darkThemeSwitch.value);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 16, right: 16, bottom: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isLightTheme
                                              ? SBUColors.background600
                                              : SBUColors.background300,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        child: SBUIconComponent(
                                          iconSize: 13.71,
                                          iconData: SBUIcons.theme,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .darkThemeTextHighEmphasis
                                              : SBUColors
                                                  .lightThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SBUTextComponent(
                                        text: strings.darkTheme,
                                        textType: SBUTextType.subtitle2,
                                        textColorType: SBUTextColorType.text01,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: SizedBox(
                                        height: 24,
                                        child: darkThemeSwitch,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _line(isLightTheme),
                          if (!kIsWeb && widget.setPushNotifications != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  pushNotificationsSwitch.onChanged!(
                                      !pushNotificationsSwitch.value);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 16, right: 16, bottom: 15),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isLightTheme
                                                ? SBUColors.secondaryMain
                                                : SBUColors.secondaryLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          alignment:
                                              AlignmentDirectional.center,
                                          child: SBUIconComponent(
                                            iconSize: 13.71,
                                            iconData:
                                                SBUIcons.notificationsFilled,
                                            iconColor: isLightTheme
                                                ? SBUColors
                                                    .darkThemeTextHighEmphasis
                                                : SBUColors
                                                    .lightThemeTextHighEmphasis,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SBUTextComponent(
                                          text: strings.pushNotifications,
                                          textType: SBUTextType.subtitle2,
                                          textColorType:
                                              SBUTextColorType.text01,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: SizedBox(
                                          height: 24,
                                          child: pushNotificationsSwitch,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (!kIsWeb && widget.setPushNotifications != null)
                            _line(isLightTheme),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                doNotDisturbSwitch
                                    .onChanged!(!doNotDisturbSwitch.value);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 16, right: 16, bottom: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isLightTheme
                                              ? SBUColors.secondaryMain
                                              : SBUColors.secondaryLight,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        child: SBUIconComponent(
                                          iconSize: 13.71,
                                          iconData:
                                              SBUIcons.notificationsFilled,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .darkThemeTextHighEmphasis
                                              : SBUColors
                                                  .lightThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SBUTextComponent(
                                        text: strings.doNotDisturb,
                                        textType: SBUTextType.subtitle2,
                                        textColorType: SBUTextColorType.text01,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: SizedBox(
                                        height: 24,
                                        child: doNotDisturbSwitch,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _line(isLightTheme),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 16, right: 16, bottom: 15),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isLightTheme
                                              ? SBUColors.errorMain
                                              : SBUColors.errorLight,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        child: SBUIconComponent(
                                          iconSize: 13.71,
                                          iconData: SBUIcons.leave,
                                          iconColor: isLightTheme
                                              ? SBUColors
                                                  .darkThemeTextHighEmphasis
                                              : SBUColors
                                                  .lightThemeTextHighEmphasis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SBUTextComponent(
                                        text: strings.exitToHome,
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

// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_menu_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_bottom_sheet_user_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_dialog_menu_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_file_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_image_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class SBUMessageListItemComponent extends SBUStatefulComponent {
  final int messageCollectionNo;
  final List<BaseMessage> messageList;
  final int messageIndex;
  final void Function(GroupChannel)? on1On1ChannelCreated;
  final void Function(UserMessage)? onOtherUserProfileTapped;

  const SBUMessageListItemComponent({
    required this.messageCollectionNo,
    required this.messageList,
    required this.messageIndex,
    this.on1On1ChannelCreated,
    this.onOtherUserProfileTapped,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUMessageListItemComponentState();
}

class SBUMessageListItemComponentState
    extends State<SBUMessageListItemComponent> {
  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final collectionProvider = SBUMessageCollectionProvider();
    final collection =
        collectionProvider.getCollection(widget.messageCollectionNo)!; // Check

    final messageList = widget.messageList;
    final messageIndex = widget.messageIndex;

    final message = messageList[messageIndex];
    final senderId = message.sender?.userId;
    final isMyMessage =
        (senderId != null && senderId == SendbirdChat.currentUser?.userId) ||
            (senderId == null) ||
            (message.sendingStatus == SendingStatus.failed);
    final isSameDayAtPreviousMessage =
        _isSameDayAtPreviousMessage(collection, messageList, messageIndex);

    Widget? messageWidget;
    if (message.messageType == MessageType.admin) {
      messageWidget = _adminMessageWidget(
        collection,
        messageList,
        messageIndex,
        message as AdminMessage,
        isLightTheme,
        strings,
      );
    } else if (message.messageType == MessageType.user) {
      if (isMyMessage) {
        messageWidget = _myUserMessageWidget(
          collection,
          messageList,
          messageIndex,
          message as UserMessage,
          isLightTheme,
          strings,
        );
      } else {
        messageWidget = _otherUserMessageWidget(
          collection,
          messageList,
          messageIndex,
          message as UserMessage,
          isLightTheme,
          strings,
          widget.onOtherUserProfileTapped,
        );
      }
    } else if (message.messageType == MessageType.file) {
      if (isMyMessage) {
        messageWidget = _myFileMessageWidget(
          collection,
          messageList,
          messageIndex,
          message as FileMessage,
          isLightTheme,
          strings,
        );
      } else {
        messageWidget = _otherFileMessageWidget(
          collection,
          messageList,
          messageIndex,
          message as FileMessage,
          isLightTheme,
          strings,
        );
      }
    }

    Widget messageWidgetWithDay = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isSameDayAtPreviousMessage == false)
          Container(
            width: double.maxFinite,
            alignment: AlignmentDirectional.center,
            padding: EdgeInsets.only(
                top: messageIndex == messageList.length - 1 ? 16 : 8,
                bottom: 8),
            child: Container(
              padding:
                  const EdgeInsets.only(left: 10, top: 4, right: 10, bottom: 4),
              decoration: BoxDecoration(
                color: isLightTheme
                    ? SBUColors.overlayLight
                    : SBUColors.overlayDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SBUTextComponent(
                text: DateFormat('EEE, MMM dd').format(
                    DateTime.fromMillisecondsSinceEpoch(message.createdAt)),
                textType: SBUTextType.caption1,
                textColorType: SBUTextColorType.messageDate,
              ),
            ),
          ),
        if (messageWidget != null) messageWidget,
      ],
    );

    return messageWidget != null ? messageWidgetWithDay : Container();
  }

  Widget? _adminMessageWidget(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
    AdminMessage message,
    bool isLightTheme,
    SBUStrings strings,
  ) {
    return Container(
      width: double.maxFinite,
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.only(
          left: 30, top: 8, right: 30, bottom: (messageIndex == 0) ? 16 : 8),
      child: SBUTextComponent(
        text: message.message,
        textType: SBUTextType.caption2,
        textColorType: SBUTextColorType.text02,
        textOverflowType: null,
        maxLines: null,
      ),
    );
  }

  Widget? _otherUserMessageWidget(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
    UserMessage message,
    bool isLightTheme,
    SBUStrings strings,
    void Function(UserMessage)? onOtherUserProfileTapped,
  ) {
    final timeString = DateFormat('h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));

    final isSameMinuteAtPreviousMessage =
        _isSameMinuteAtPreviousMessage(messageList, messageIndex);
    final isSameMinuteAtNextMessage =
        _isSameMinuteAtNextMessage(messageList, messageIndex);

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        top: isSameMinuteAtPreviousMessage ? 1 : 8,
        right: 12,
        bottom: isSameMinuteAtNextMessage
            ? 1
            : (messageIndex == 0)
                ? 16
                : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 2),
            child: (isSameMinuteAtNextMessage == false)
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (onOtherUserProfileTapped != null)
                          return onOtherUserProfileTapped(message);

                        if (message.sender != null) {
                          widget.unfocus();
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            builder: (context) {
                              return SBUBottomSheetUserComponent(
                                user: message.sender!,
                                on1On1ChannelCreated:
                                    widget.on1On1ChannelCreated,
                              );
                            },
                          );
                        }
                      },
                      child: widget.getAvatarComponent(
                        isLightTheme: isLightTheme,
                        size: 26,
                        user: message.sender,
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 26,
                  ),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSameMinuteAtPreviousMessage == false)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: SBUTextComponent(
                      text: widget.getNickname(message.sender, strings),
                      textType: SBUTextType.caption1,
                      textColorType: SBUTextColorType.text02,
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onLongPress: () async {
                      widget.unfocus();
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
                            iconNames: [
                              SBUIcons.copy,
                            ],
                            buttonNames: [
                              strings.copy,
                            ],
                            onButtonClicked: (buttonName) async {
                              if (buttonName == strings.copy) {
                                await widget.copyTextToClipboard(
                                    message.message, strings);
                              }
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 12, top: 6, right: 12, bottom: 6),
                      decoration: BoxDecoration(
                        color: isLightTheme
                            ? SBUColors.background100
                            : SBUColors.background400,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: SBUTextComponent(
                              text: message.message,
                              textType: SBUTextType.body3,
                              textColorType: SBUTextColorType.text01,
                              textOverflowType: null,
                              maxLines: null,
                            ),
                          ),
                          if (message.updatedAt > message.createdAt)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: SBUTextComponent(
                                text: strings.edited,
                                textType: SBUTextType.body3,
                                textColorType: SBUTextColorType.text02,
                                textOverflowType: null,
                                maxLines: null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSameMinuteAtNextMessage == false)
            Container(
              height: 16,
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(left: 4),
              child: SBUTextComponent(
                text: timeString,
                textType: SBUTextType.caption4,
                textColorType: SBUTextColorType.text03,
              ),
            ),
        ],
      ),
    );
  }

  Widget? _myUserMessageWidget(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
    UserMessage message,
    bool isLightTheme,
    SBUStrings strings,
  ) {
    final timeString = DateFormat('h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));

    final isSameMinuteAtPreviousMessage =
        _isSameMinuteAtPreviousMessage(messageList, messageIndex);
    final isSameMinuteAtNextMessage =
        _isSameMinuteAtNextMessage(messageList, messageIndex);

    final readStatusIcon =
        widget.getReadStatusIcon(collection.channel, message, isLightTheme);

    final isDisabled = widget.isDisabled(collection.channel);

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        top: isSameMinuteAtPreviousMessage ? 1 : 8,
        right: 12,
        bottom: isSameMinuteAtNextMessage
            ? 1
            : (messageIndex == 0)
                ? 16
                : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (readStatusIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: readStatusIcon,
            ),
          if (message.sendingStatus == SendingStatus.pending)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: isLightTheme
                        ? SBUColors.primaryMain
                        : SBUColors.primaryLight,
                    strokeWidth: 1.4),
              ),
            ),
          if (message.sendingStatus == SendingStatus.failed)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: SBUIconComponent(
                iconSize: 16,
                iconData: SBUIcons.error,
                iconColor:
                    isLightTheme ? SBUColors.errorMain : SBUColors.errorLight,
              ),
            ),
          if (message.sendingStatus == SendingStatus.succeeded &&
              isSameMinuteAtNextMessage == false)
            Container(
              height: 16,
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(right: 4),
              child: SBUTextComponent(
                text: timeString,
                textType: SBUTextType.caption4,
                textColorType: SBUTextColorType.text03,
              ),
            ),
          Flexible(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onLongPress: () async {
                  if (message.sendingStatus == SendingStatus.succeeded) {
                    widget.unfocus();
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
                          iconNames: [
                            SBUIcons.copy,
                            if (!isDisabled) SBUIcons.edit,
                            if (!isDisabled) SBUIcons.delete,
                          ],
                          buttonNames: [
                            strings.copy,
                            if (!isDisabled) strings.edit,
                            if (!isDisabled) strings.delete,
                          ],
                          onButtonClicked: (buttonName) async {
                            if (buttonName == strings.copy) {
                              await widget.copyTextToClipboard(
                                  message.message, strings);
                            } else if (buttonName == strings.edit) {
                              SBUMessageCollectionProvider().setEditingMessage(
                                  widget.messageCollectionNo, message);
                            } else if (buttonName == strings.delete) {
                              await showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => SBUDialogMenuComponent(
                                  title: strings.deleteMessage,
                                  buttonNames: [
                                    strings.cancel,
                                    strings.delete,
                                  ],
                                  onButtonClicked: (buttonName) async {
                                    if (buttonName == strings.cancel) {
                                      // Cancel
                                    } else if (buttonName == strings.delete) {
                                      runZonedGuarded(() async {
                                        await collection.channel
                                            .deleteMessage(message.messageId);
                                      }, (error, stack) {
                                        // TODO: Check error
                                      });
                                    }
                                  },
                                  isYesOrNo: true,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (message.sendingStatus == SendingStatus.failed) {
                    widget.unfocus();
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
                            if (!isDisabled) strings.retry,
                            strings.remove,
                          ],
                          onButtonClicked: (buttonName) async {
                            if (buttonName == strings.retry) {
                              try {
                                collection.channel.resendUserMessage(message);
                              } catch (e) {
                                // TODO: Check error
                              }
                            } else if (buttonName == strings.remove) {
                              await collection
                                  .removeFailedMessages(messages: [message]);
                            }
                          },
                          errorColorIndex: 1,
                        );
                      },
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 12, top: 7, right: 12, bottom: 7),
                  decoration: BoxDecoration(
                    color: isLightTheme
                        ? SBUColors.primaryMain
                        : SBUColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: SBUTextComponent(
                          text: message.message,
                          textType: SBUTextType.body3,
                          textColorType: SBUTextColorType.message,
                          textOverflowType: null,
                          maxLines: null,
                        ),
                      ),
                      if (message.updatedAt > message.createdAt)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SBUTextComponent(
                            text: strings.edited,
                            textType: SBUTextType.body3,
                            textColorType: SBUTextColorType.messageEdited,
                            textOverflowType: null,
                            maxLines: null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget? _otherFileMessageWidget(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
    FileMessage message,
    bool isLightTheme,
    SBUStrings strings,
  ) {
    final timeString = DateFormat('h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));

    final isSameMinuteAtPreviousMessage =
        _isSameMinuteAtPreviousMessage(messageList, messageIndex);
    final isSameMinuteAtNextMessage =
        _isSameMinuteAtNextMessage(messageList, messageIndex);

    final fileWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SBUFileIconComponent(
            size: 28,
            backgroundColor:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
            iconSize: 24,
            iconData: SBUIcons.fileDocument,
            iconColor:
                isLightTheme ? SBUColors.primaryMain : SBUColors.primaryLight,
          ),
        ),
        Flexible(
          child: SBUTextComponent(
            text: message.name ?? '',
            textType: SBUTextType.body3,
            textColorType: SBUTextColorType.text01,
            // SBUTextOverflowType.ellipsisMiddle
            textOverflowType: null,
            maxLines: null, // 1
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        top: isSameMinuteAtPreviousMessage ? 1 : 8,
        right: 12,
        bottom: isSameMinuteAtNextMessage
            ? 1
            : (messageIndex == 0)
                ? 16
                : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 2),
            child: (isSameMinuteAtNextMessage == false)
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (message.sender != null) {
                          widget.unfocus();
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            builder: (context) {
                              return SBUBottomSheetUserComponent(
                                user: message.sender!,
                                on1On1ChannelCreated:
                                    widget.on1On1ChannelCreated,
                              );
                            },
                          );
                        }
                      },
                      child: widget.getAvatarComponent(
                        isLightTheme: isLightTheme,
                        size: 26,
                        user: message.sender,
                      ),
                    ),
                  )
                : const SizedBox(width: 26),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSameMinuteAtPreviousMessage == false)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: SBUTextComponent(
                      text: widget.getNickname(message.sender, strings),
                      textType: SBUTextType.caption1,
                      textColorType: SBUTextColorType.text02,
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onLongPress: () async {
                      if (SendbirdUIKit().downloadFile == null) {
                        return;
                      }

                      widget.unfocus();
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
                            iconNames: [
                              if (SendbirdUIKit().downloadFile != null)
                                SBUIcons.download,
                            ],
                            buttonNames: [
                              if (SendbirdUIKit().downloadFile != null)
                                strings.save,
                            ],
                            onButtonClicked: (buttonName) {
                              if (buttonName == strings.save) {
                                SendbirdUIKit().downloadFile!(
                                  message.secureUrl,
                                  message.name,
                                  () => widget.showToast(
                                    isLightTheme: isLightTheme,
                                    text: strings.fileSaved,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: widget.isImage(message.name)
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(
                              left: 12, top: 8, right: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: widget.isImage(message.name)
                            ? isLightTheme
                                ? SBUColors.background100
                                : SBUColors.background400
                            : isLightTheme
                                ? SBUColors.background100
                                : SBUColors.background400,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: widget.isImage(message.name)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 240, // Check
                                height: 160,
                                child: SBUImageComponent(
                                  imageUrl: message.secureUrl,
                                  cacheKey: widget.getImageCacheKey(message),
                                  errorWidget: SBUIconComponent(
                                    iconSize: 48,
                                    iconData: SBUIcons.photo,
                                    iconColor: isLightTheme
                                        ? SBUColors.lightThemeTextMidEmphasis
                                        : SBUColors.darkThemeTextMidEmphasis,
                                  ),
                                ),
                              ),
                            )
                          : fileWidget,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSameMinuteAtNextMessage == false)
            Container(
              height: 16,
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(left: 4),
              child: SBUTextComponent(
                text: timeString,
                textType: SBUTextType.caption4,
                textColorType: SBUTextColorType.text03,
              ),
            ),
        ],
      ),
    );
  }

  Widget? _myFileMessageWidget(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
    FileMessage message,
    bool isLightTheme,
    SBUStrings strings,
  ) {
    final timeString = DateFormat('h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(message.createdAt));

    final isSameMinuteAtPreviousMessage =
        _isSameMinuteAtPreviousMessage(messageList, messageIndex);
    final isSameMinuteAtNextMessage =
        _isSameMinuteAtNextMessage(messageList, messageIndex);

    final readStatusIcon =
        widget.getReadStatusIcon(collection.channel, message, isLightTheme);

    final isDisabled = widget.isDisabled(collection.channel);

    final fileWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SBUFileIconComponent(
            size: 28,
            backgroundColor:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
            iconSize: 24,
            iconData: SBUIcons.fileDocument,
            iconColor:
                isLightTheme ? SBUColors.primaryMain : SBUColors.primaryLight,
          ),
        ),
        Flexible(
          child: SBUTextComponent(
            text: message.name ?? '',
            textType: SBUTextType.body3,
            textColorType: SBUTextColorType.message,
            // SBUTextOverflowType.ellipsisMiddle
            textOverflowType: null,
            maxLines: null, // 1
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        top: isSameMinuteAtPreviousMessage ? 1 : 8,
        right: 12,
        bottom: isSameMinuteAtNextMessage
            ? 1
            : (messageIndex == 0)
                ? 16
                : 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (readStatusIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: readStatusIcon,
            ),
          if (message.sendingStatus == SendingStatus.pending)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: isLightTheme
                        ? SBUColors.primaryMain
                        : SBUColors.primaryLight,
                    strokeWidth: 1.4),
              ),
            ),
          if (message.sendingStatus == SendingStatus.failed)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: SBUIconComponent(
                iconSize: 16,
                iconData: SBUIcons.error,
                iconColor:
                    isLightTheme ? SBUColors.errorMain : SBUColors.errorLight,
              ),
            ),
          if (message.sendingStatus == SendingStatus.succeeded &&
              isSameMinuteAtNextMessage == false)
            Container(
              height: 16,
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(right: 4),
              child: SBUTextComponent(
                text: timeString,
                textType: SBUTextType.caption4,
                textColorType: SBUTextColorType.text03,
              ),
            ),
          Flexible(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onLongPress: () async {
                  if (message.sendingStatus == SendingStatus.succeeded) {
                    if (SendbirdUIKit().downloadFile == null && isDisabled) {
                      return;
                    }

                    widget.unfocus();
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
                          iconNames: [
                            if (SendbirdUIKit().downloadFile != null)
                              SBUIcons.download,
                            if (!isDisabled) SBUIcons.delete,
                          ],
                          buttonNames: [
                            if (SendbirdUIKit().downloadFile != null)
                              strings.save,
                            if (!isDisabled) strings.delete,
                          ],
                          onButtonClicked: (buttonName) async {
                            if (buttonName == strings.save) {
                              SendbirdUIKit().downloadFile!(
                                message.secureUrl,
                                message.name,
                                () => widget.showToast(
                                  isLightTheme: isLightTheme,
                                  text: strings.fileSaved,
                                ),
                              );
                            } else if (buttonName == strings.delete) {
                              await showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => SBUDialogMenuComponent(
                                  title: strings.deleteMessage,
                                  buttonNames: [
                                    strings.cancel,
                                    strings.delete,
                                  ],
                                  onButtonClicked: (buttonName) async {
                                    if (buttonName == strings.cancel) {
                                      // Cancel
                                    } else if (buttonName == strings.delete) {
                                      if (message.sendingStatus ==
                                          SendingStatus.succeeded) {
                                        runZonedGuarded(() async {
                                          await collection.channel
                                              .deleteMessage(message.messageId);
                                        }, (error, stack) {
                                          // TODO: Check error
                                        });
                                      } else if (message.sendingStatus ==
                                          SendingStatus.failed) {
                                        await collection.removeFailedMessages(
                                            messages: [message]);
                                      }
                                    }
                                  },
                                  isYesOrNo: true,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (message.sendingStatus == SendingStatus.failed) {
                    widget.unfocus();
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
                            if (!isDisabled) strings.retry,
                            strings.remove,
                          ],
                          onButtonClicked: (buttonName) async {
                            if (buttonName == strings.retry) {
                              try {
                                collection.channel.resendFileMessage(message);
                              } catch (e) {
                                if (e is FileSizeLimitExceededException) {
                                  // TODO: Check error
                                } else {
                                  // TODO: Check error
                                }
                              }
                            } else if (buttonName == strings.remove) {
                              await collection
                                  .removeFailedMessages(messages: [message]);
                            }
                          },
                          errorColorIndex: 1,
                        );
                      },
                    );
                  }
                },
                child: Container(
                  padding: widget.isImage(message.name)
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(
                          left: 12, top: 7, right: 12, bottom: 7),
                  decoration: BoxDecoration(
                    color: widget.isImage(message.name)
                        ? isLightTheme
                            ? SBUColors.background100
                            : SBUColors.background400
                        : isLightTheme
                            ? SBUColors.primaryMain
                            : SBUColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.isImage(message.name)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 240, // Check
                            height: 160,
                            child: SBUImageComponent(
                              imageUrl: message.secureUrl,
                              cacheKey: widget.getImageCacheKey(message),
                              errorWidget:
                                  // Check
                                  // message.file != null
                                  //     ? Image.file(
                                  //         message.file!,
                                  //         fit: BoxFit.cover,
                                  //       )
                                  //     :
                                  SBUIconComponent(
                                iconSize: 48,
                                iconData: SBUIcons.photo,
                                iconColor: isLightTheme
                                    ? SBUColors.lightThemeTextMidEmphasis
                                    : SBUColors.darkThemeTextMidEmphasis,
                              ),
                            ),
                          ),
                        )
                      : fileWidget,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _isSameDayAtPreviousMessage(
    MessageCollection collection,
    List<BaseMessage> messageList,
    int messageIndex,
  ) {
    final message = messageList[messageIndex];

    if (messageIndex == messageList.length - 1) {
      if (collection.isLoading) {
        return true; // Do not draw date.
      }

      // reverse
      if (collection.hasPrevious) {
        return true; // Do not draw date.
      }
    }

    // reverse
    if (messageIndex + 1 < messageList.length) {
      final prevMessage = messageList[messageIndex + 1];
      return _isSameDay(message.createdAt, prevMessage.createdAt);
    }
    return false;
  }

  bool _isSameDay(int ts1, int ts2) {
    final dt1 = DateTime.fromMillisecondsSinceEpoch(ts1);
    final dt2 = DateTime.fromMillisecondsSinceEpoch(ts2);

    if (dt1.year == dt2.year && dt1.month == dt2.month && dt1.day == dt2.day) {
      return true;
    }
    return false;
  }

  bool _isSameMinuteAtPreviousMessage(
    List<BaseMessage> messageList,
    int messageIndex,
  ) {
    final message = messageList[messageIndex];

    // reverse
    if (messageIndex + 1 < messageList.length) {
      final prevMessage = messageList[messageIndex + 1];
      return _isSameMinute(message.createdAt, prevMessage.createdAt) &&
          _isSameSender(message, prevMessage);
    }
    return false;
  }

  bool _isSameMinuteAtNextMessage(
    List<BaseMessage> messageList,
    int messageIndex,
  ) {
    final message = messageList[messageIndex];

    // reverse
    if (messageIndex - 1 >= 0) {
      final nextMessage = messageList[messageIndex - 1];
      return _isSameMinute(message.createdAt, nextMessage.createdAt) &&
          _isSameSender(message, nextMessage);
    }
    return false;
  }

  bool _isSameMinute(int ts1, int ts2) {
    final dt1 = DateTime.fromMillisecondsSinceEpoch(ts1);
    final dt2 = DateTime.fromMillisecondsSinceEpoch(ts2);

    if (dt1.year == dt2.year &&
        dt1.month == dt2.month &&
        dt1.day == dt2.day &&
        dt1.hour == dt2.hour &&
        dt1.minute == dt2.minute) {
      return true;
    }
    return false;
  }

  bool _isSameSender(BaseMessage m1, BaseMessage m2) {
    return m1.sender?.userId == m2.sender?.userId;
  }
}

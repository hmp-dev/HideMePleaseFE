// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_button_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_icon_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_placeholder_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_scroll_bar_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_message_input_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_message_list_item_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelScreen
class SBUGroupChannelScreen extends SBUStatefulComponent {
  static const double defaultScrollExtentToTriggerPreloading = 4000; // Check
  static const double defaultCacheExtent = 4000; // Check

  final String channelUrl;
  final MessageListParams? params;
  final void Function(int messageCollectionNo)? onMessageCollectionReady;
  final void Function(ScrollController)? onScrollControllerReady;
  final void Function(GroupChannel)? onChannelDeleted;
  final void Function(int messageCollectionNo)? onInfoButtonClicked;
  final void Function(GroupChannel)? on1On1ChannelCreated;
  final void Function(UserMessage)? onOtherUserProfileTapped;
  final double scrollExtentToTriggerPreloading;
  final double cacheExtent;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
  )? customHeader;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
    int index,
    BaseMessage message,
  )? customListItem;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
  )? customMessageInput;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
  )? customLoadingBody;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
  )? customEmptyBody;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
  )? customErrorScreen;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    MessageCollection collection,
  )? customFrozenChannel;

  const SBUGroupChannelScreen({
    required this.channelUrl,
    this.params,
    this.onMessageCollectionReady,
    this.onScrollControllerReady,
    this.onChannelDeleted,
    this.onInfoButtonClicked,
    this.on1On1ChannelCreated,
    this.onOtherUserProfileTapped,
    this.scrollExtentToTriggerPreloading =
        defaultScrollExtentToTriggerPreloading,
    this.cacheExtent = defaultCacheExtent,
    this.customHeader,
    this.customListItem,
    this.customMessageInput,
    this.customLoadingBody,
    this.customEmptyBody,
    this.customErrorScreen,
    this.customFrozenChannel,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUGroupChannelScreenState();
}

class SBUGroupChannelScreenState extends State<SBUGroupChannelScreen>
    with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();

  int? collectionNo;
  bool isLoading = true;
  bool isError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    FToast().init(context); // Check
    _init();
  }

  void _init() async {
    try {
      isError = false;

      await _initialize();
    } catch (_) {
      if (mounted) {
        setState(() {
          isError = true;
        });
      }
    }
  }

  Future<void> _initialize() async {
    final collectionProvider = SBUMessageCollectionProvider();
    final channel = await GroupChannel.getChannelFromCache(widget.channelUrl) ??
        await GroupChannel.getChannel(widget.channelUrl);

    collectionNo = collectionProvider.add(
      channel: channel,
      params: widget.params,
    );

    if (collectionNo != null && widget.onMessageCollectionReady != null) {
      widget.onMessageCollectionReady!(collectionNo!);
    }

    if (mounted) {
      setState(() {});
    }

    final collection = collectionNo != null
        ? collectionProvider.getCollection(collectionNo!)
        : null;

    if (collection != null) {
      await collection.initialize();

      if (mounted) {
        final checkOnPostFrame = isLoading;

        setState(() {
          isLoading = false;
        });

        runZonedGuarded(() async {
          // Check if no scrollbar
          if (checkOnPostFrame) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              if (collection.messageList.isNotEmpty) {
                if (scrollController.position.maxScrollExtent == 0) {
                  await _loadPrevious(collection);
                }

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (widget.onScrollControllerReady != null) {
                    widget.onScrollControllerReady!(scrollController);
                  }
                });
              }
            });
          }
        }, (error, stack) {
          // TODO: Check error
        });
      }
    }
  }

  Future<void> _loadPrevious(MessageCollection collection) async {
    if (!collection.isLoading && collection.hasPrevious) {
      await collection.loadPrevious();

      if (mounted) {
        if (collection.messageList.isNotEmpty) {
          if (scrollController.position.maxScrollExtent == 0) {
            await _loadPrevious(collection);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    if (collectionNo != null) {
      SBUMessageCollectionProvider().remove(collectionNo!);
    }
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final themeProvider = context.watch<SBUThemeProvider>();
    final theme = themeProvider.theme;
    final isLightTheme = themeProvider.isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final collectionProvider = context.watch<SBUMessageCollectionProvider>();

    if (isError) {
      if (widget.customErrorScreen != null) {
        return widget.getDefaultContainer(
          isLightTheme,
          child: widget.customErrorScreen!(
            context,
            theme,
            strings,
          ),
        );
      }
      return widget.getDefaultContainer(
        isLightTheme,
        child: SBUPlaceholderComponent(
          isLightTheme: isLightTheme,
          iconData: SBUIcons.error,
          text: strings.somethingWentWrong,
          retryText: strings.retry,
          onRetryButtonClicked: () {
            _init();
          },
        ),
      );
    }

    if (collectionNo == null) {
      return widget.getDefaultContainer(isLightTheme);
    }

    final collection = collectionProvider.getCollection(collectionNo!);
    final isScrollToEnd = collectionProvider.isScrollToEnd(collectionNo!);
    final isDeletedChannel = collectionProvider.isDeletedChannel(collectionNo!);

    if (isScrollToEnd) {
      collectionProvider.resetScrollToEnd(collectionNo!);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scrollController.jumpTo(0);
      });
    }

    if (isDeletedChannel) {
      collectionProvider.resetDeletedChannel(collectionNo!);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (collection != null) {
          if (widget.onChannelDeleted != null) {
            widget.onChannelDeleted!(collection.channel);
          }
        }
      });
    }

    final header = collection != null
        ? SBUHeaderComponent(
            width: double.maxFinite,
            height: 56,
            backgroundColor:
                isLightTheme ? SBUColors.background50 : SBUColors.background500,
            title: SBUTextComponent(
              text: widget.getGroupChannelName(collection.channel, strings),
              textType: SBUTextType.heading2,
              textColorType: SBUTextColorType.text01,
            ),
            hasBackKey: Navigator.of(context).canPop(),
            avatar: widget.getGroupChannelAvatarComponent(
              isLightTheme: isLightTheme,
              size: 34,
              channel: collection.channel,
            ),
            iconButton: widget.onInfoButtonClicked != null
                ? SBUIconButtonComponent(
                    iconButtonSize: 32,
                    icon: SBUIconComponent(
                      iconSize: 24,
                      iconData: SBUIcons.info,
                      iconColor: isLightTheme
                          ? SBUColors.primaryMain
                          : SBUColors.primaryLight,
                    ),
                    onButtonClicked: () {
                      widget.unfocus();
                      if (widget.onInfoButtonClicked != null) {
                        widget.onInfoButtonClicked!(collectionNo!);
                      }
                    },
                  )
                : null,
            channelForTypingStatus: collection.channel,
          )
        : null;

    final list = collection != null && collection.messageList.isNotEmpty
        ? NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      widget.scrollExtentToTriggerPreloading) {
                _loadPrevious(collection);
              }
              return false;
            },
            child: SBUScrollBarComponent(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                shrinkWrap: false,
                itemCount: collection.messageList.length,
                cacheExtent: widget.cacheExtent,
                itemBuilder: (context, index) {
                  return widget.customListItem != null
                      ? widget.customListItem!(
                          context,
                          theme,
                          strings,
                          collection,
                          index,
                          collection.messageList[index],
                        )
                      : SBUMessageListItemComponent(
                          messageCollectionNo: collectionNo!,
                          messageList: collection.messageList,
                          messageIndex: index,
                          on1On1ChannelCreated: widget.on1On1ChannelCreated,
                          onOtherUserProfileTapped:
                              widget.onOtherUserProfileTapped,
                        );
                },
              ),
            ),
          )
        : null;

    final body = collection == null
        ? widget.getDefaultContainer(isLightTheme)
        : isLoading && collection.messageList.isEmpty
            ? (widget.customLoadingBody != null
                ? widget.customLoadingBody!(
                    context,
                    theme,
                    strings,
                    collection,
                  )
                : widget.getDefaultContainer(
                    isLightTheme,
                    child: Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          color: isLightTheme
                              ? SBUColors.primaryMain
                              : SBUColors.primaryLight,
                          strokeWidth: 5.5,
                        ),
                      ),
                    ),
                  ))
            : (collection.messageList.isEmpty
                ? (widget.customEmptyBody != null
                    ? widget.getDefaultContainer(
                        isLightTheme,
                        child: widget.customEmptyBody!(
                          context,
                          theme,
                          strings,
                          collection,
                        ),
                      )
                    : widget.getDefaultContainer(
                        isLightTheme,
                        child: SBUPlaceholderComponent(
                          isLightTheme: isLightTheme,
                          iconData: SBUIcons.message,
                          text: strings.noMessages,
                        ),
                      ))
                : list ?? widget.getDefaultContainer(isLightTheme));

    final messageInput = collection != null
        ? SBUMessageInputComponent(
            messageCollectionNo: collectionNo!,
            backgroundColor:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
          )
        : null;

    return Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          collection == null
              ? widget.getDefaultContainer(isLightTheme)
              : widget.customHeader != null
                  ? widget.customHeader!(
                      context,
                      theme,
                      strings,
                      collection,
                    )
                  : header ??
                      Container(
                        color: isLightTheme
                            ? SBUColors.background50
                            : SBUColors.background500,
                      ),
          Expanded(
            child: Container(
              color: isLightTheme
                  ? SBUColors.background50
                  : SBUColors.background600,
              alignment: Alignment.bottomCenter,
              child: body,
            ),
          ),
          collection == null
              ? widget.getDefaultContainer(isLightTheme)
              : widget.customMessageInput != null
                  ? widget.customMessageInput!(
                      context,
                      theme,
                      strings,
                      collection,
                    )
                  : messageInput ?? widget.getDefaultContainer(isLightTheme),
        ],
      ),
      if (collection?.channel.isFrozen ?? false)
        collection == null
            ? widget.getDefaultContainer(isLightTheme)
            : widget.customFrozenChannel != null
                ? widget.customFrozenChannel!(
                    context,
                    theme,
                    strings,
                    collection,
                  )
                : Container(
                    width: double.maxFinite,
                    height: 24,
                    margin: const EdgeInsets.only(left: 8, top: 88, right: 8),
                    decoration: BoxDecoration(
                      color: SBUColors.informationLight,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Center(
                      child: SBUTextComponent(
                        text: strings.channelIsFrozen,
                        textType: SBUTextType.caption2,
                        textColorType: SBUTextColorType.information,
                      ),
                    ),
                  ),
    ]);
  }
}

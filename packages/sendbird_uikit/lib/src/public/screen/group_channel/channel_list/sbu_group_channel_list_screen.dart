// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

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
import 'package:sendbird_uikit/src/internal/component/module/sbu_group_channel_list_item_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_group_channel_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelListScreen
class SBUGroupChannelListScreen extends SBUStatefulComponent {
  static const double defaultScrollExtentToTriggerPreloading = 2000; // Check
  static const double defaultCacheExtent = 2000; // Check

  final GroupChannelListQuery? query;
  final void Function(int channelCollectionNo)? onGroupChannelCollectionReady;
  final void Function(ScrollController)? onScrollControllerReady;
  final void Function()? onCreateButtonClicked;
  final void Function(GroupChannel)? onListItemClicked;
  final double scrollExtentToTriggerPreloading;
  final double cacheExtent;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    GroupChannelCollection collection,
  )? customHeader;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    GroupChannelCollection collection,
    int index,
    GroupChannel channel,
  )? customListItem;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    GroupChannelCollection collection,
  )? customLoadingBody;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
    GroupChannelCollection collection,
  )? customEmptyBody;

  final Widget Function(
    BuildContext context,
    SBUTheme theme,
    SBUStrings strings,
  )? customErrorScreen;

  const SBUGroupChannelListScreen({
    this.query,
    this.onGroupChannelCollectionReady,
    this.onScrollControllerReady,
    this.onCreateButtonClicked,
    this.onListItemClicked,
    this.scrollExtentToTriggerPreloading =
        defaultScrollExtentToTriggerPreloading,
    this.cacheExtent = defaultCacheExtent,
    this.customHeader,
    this.customListItem,
    this.customLoadingBody,
    this.customEmptyBody,
    this.customErrorScreen,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUGroupChannelListScreenState();
}

class SBUGroupChannelListScreenState extends State<SBUGroupChannelListScreen>
    with AutomaticKeepAliveClientMixin {
  final scrollController = ScrollController();

  late int collectionNo;
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
    final collectionProvider = SBUGroupChannelCollectionProvider();
    collectionNo = collectionProvider.add(query: widget.query);

    if (widget.onGroupChannelCollectionReady != null) {
      widget.onGroupChannelCollectionReady!(collectionNo);
    }

    _loadMore();
  }

  Future<void> _loadMore() async {
    try {
      isError = false;

      final collectionProvider = SBUGroupChannelCollectionProvider();
      final collection = collectionProvider.getCollection(collectionNo);

      if (collection != null) {
        if (!collection.isLoading && collection.hasMore) {
          await collection.loadMore();

          if (mounted) {
            final checkOnPostFrame = isLoading;

            if (isLoading) {
              setState(() {
                isLoading = false;
              });
            }

            // Check if no scrollbar
            if (checkOnPostFrame) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                if (collection.channelList.isNotEmpty) {
                  if (scrollController.position.maxScrollExtent == 0) {
                    await _loadMore();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    if (widget.onScrollControllerReady != null) {
                      widget.onScrollControllerReady!(scrollController);
                    }
                  });
                }
              });
            } else {
              if (collection.channelList.isNotEmpty) {
                if (scrollController.position.maxScrollExtent == 0) {
                  await _loadMore();
                }
              }
            }
          }
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    SBUGroupChannelCollectionProvider().remove(collectionNo);
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

    final collection = context
        .watch<SBUGroupChannelCollectionProvider>()
        .getCollection(collectionNo);

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
          onRetryButtonClicked: () async {
            await _loadMore();
          },
        ),
      );
    }

    final header = SBUHeaderComponent(
      width: double.maxFinite,
      height: 56,
      backgroundColor:
          isLightTheme ? SBUColors.background50 : SBUColors.background500,
      title: SBUTextComponent(
        text: strings.channels,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: false,
      iconButton: widget.onCreateButtonClicked != null
          ? SBUIconButtonComponent(
              iconButtonSize: 32,
              icon: SBUIconComponent(
                iconSize: 24,
                iconData: SBUIcons.create,
                iconColor: isLightTheme
                    ? SBUColors.primaryMain
                    : SBUColors.primaryLight,
              ),
              onButtonClicked: widget.onCreateButtonClicked,
            )
          : null,
    );

    final list = collection != null
        ? NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent -
                      widget.scrollExtentToTriggerPreloading) {
                _loadMore();
              }
              return false;
            },
            child: SBUScrollBarComponent(
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                itemCount: collection.channelList.length,
                cacheExtent: widget.cacheExtent,
                itemBuilder: (context, index) {
                  return widget.customListItem != null
                      ? widget.customListItem!(
                          context,
                          theme,
                          strings,
                          collection,
                          index,
                          collection.channelList[index],
                        )
                      : SBUGroupChannelListItemComponent(
                          width: double.maxFinite,
                          height: 76,
                          channel: collection.channelList[index],
                          onListItemClicked: widget.onListItemClicked,
                        );
                },
              ),
            ),
          )
        : null;

    final body = collection == null
        ? widget.getDefaultContainer(isLightTheme)
        : isLoading && collection.channelList.isEmpty
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
            : (collection.channelList.isEmpty
                ? (widget.customEmptyBody != null
                    ? SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
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
                          iconData: SBUIcons.chat,
                          text: strings.noChannels,
                        ),
                      ))
                : list ?? widget.getDefaultContainer(isLightTheme));

    return Column(
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
                : header,
        Expanded(
          child: widget.getDefaultContainer(
            isLightTheme,
            child: body,
          ),
        ),
      ],
    );
  }
}

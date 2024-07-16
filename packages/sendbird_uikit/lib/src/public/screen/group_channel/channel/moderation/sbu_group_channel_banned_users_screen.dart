// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_placeholder_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_scroll_bar_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_user_list_item_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelBannedUsersScreen
class SBUGroupChannelBannedUsersScreen extends SBUStatefulComponent {
  final int messageCollectionNo;

  const SBUGroupChannelBannedUsersScreen({
    required this.messageCollectionNo,
    super.key,
  });

  @override
  State<StatefulWidget> createState() =>
      SBUGroupChannelBannedUsersScreenState();
}

class SBUGroupChannelBannedUsersScreenState
    extends State<SBUGroupChannelBannedUsersScreen> {
  final channelHandlerIdentifier = '1';
  final scrollController = ScrollController();
  late BannedUserListQuery query;

  List<User> bannedUserList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    SendbirdChat.addChannelHandler(
        channelHandlerIdentifier, _BannedUsersGroupChannelHandler(this));

    _initQuery();
    _next();
  }

  void _initQuery() {
    final channel = SBUMessageCollectionProvider()
        .getCollection(widget.messageCollectionNo)
        ?.channel;

    if (channel != null) {
      query = BannedUserListQuery(
        channelType: ChannelType.group,
        channelUrl: channel.channelUrl,
      );
      bannedUserList.clear();
    }
  }

  void _next() {
    runZonedGuarded(() {
      query.next().then((users) {
        if (mounted) {
          setState(() {
            isLoading = false;
            bannedUserList.addAll(users);
          });

          // Check if no scrollbar
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (bannedUserList.isNotEmpty) {
              if (scrollController.position.maxScrollExtent == 0) {
                if (!query.isLoading && query.hasNext) {
                  _next();
                }
              }
            }
          });
        }
      });
    }, (error, stack) {
      // TODO: Check error
    });
  }

  @override
  void dispose() {
    SendbirdChat.removeChannelHandler(channelHandlerIdentifier);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = context.watch<SBUThemeProvider>().isLight();
    final strings = context.watch<SBUStringProvider>().strings;

    final channel = context
        .watch<SBUMessageCollectionProvider>()
        .getCollection(widget.messageCollectionNo)
        ?.channel;

    final header = SBUHeaderComponent(
      width: double.maxFinite,
      height: 56,
      backgroundColor:
          isLightTheme ? SBUColors.background50 : SBUColors.background500,
      title: SBUTextComponent(
        text: strings.bannedUsers,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: true,
    );

    final sortedMembers = widget.sortUsersByNickname(bannedUserList);
    final myMember = widget.getMyMember(channel);

    return Column(
      children: [
        header,
        Expanded(
          child: Container(
            width: double.maxFinite,
            color:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
            child: channel != null && sortedMembers.isNotEmpty
                ? NotificationListener(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent) {
                        if (!query.isLoading && query.hasNext) {
                          _next();
                        }
                      }
                      return false;
                    },
                    child: SBUScrollBarComponent(
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: sortedMembers.length,
                        itemBuilder: (context, i) {
                          return SBUUserListItemComponent(
                            width: double.maxFinite,
                            height: 56,
                            backgroundColor: isLightTheme
                                ? SBUColors.background50
                                : SBUColors.background600,
                            channel: channel,
                            user: sortedMembers[i],
                            canOperate: myMember?.role == Role.operator,
                            moderationType: SBUModerationType.bannedUsers,
                          );
                        },
                      ),
                    ),
                  )
                : widget.getDefaultContainer(
                    isLightTheme,
                    child: isLoading
                        ? Container()
                        : SBUPlaceholderComponent(
                            isLightTheme: isLightTheme,
                            iconData: SBUIcons.ban,
                            text: strings.noBannedUsers,
                          ),
                  ),
          ),
        ),
      ],
    );
  }

  void onUserBanned(BaseChannel channel, RestrictedUser restrictedUser) {
    final collection = SBUMessageCollectionProvider()
        .getCollection(widget.messageCollectionNo);
    if (collection?.channel.channelUrl == channel.channelUrl) {
      setState(() {
        bannedUserList.add(restrictedUser);
      });
    }
  }

  void onUserUnbanned(BaseChannel channel, User user) {
    final collection = SBUMessageCollectionProvider()
        .getCollection(widget.messageCollectionNo);
    if (collection?.channel.channelUrl == channel.channelUrl) {
      setState(() {
        bannedUserList
            .removeWhere((bannedUser) => bannedUser.userId == user.userId);
      });
    }
  }
}

class _BannedUsersGroupChannelHandler extends GroupChannelHandler {
  final SBUGroupChannelBannedUsersScreenState state;

  _BannedUsersGroupChannelHandler(this.state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {}

  @override
  void onUserBanned(BaseChannel channel, RestrictedUser restrictedUser) {
    state.onUserBanned(channel, restrictedUser);
  }

  @override
  void onUserUnbanned(BaseChannel channel, User user) {
    state.onUserUnbanned(channel, user);
  }
}

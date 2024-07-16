// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/base/sbu_base_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_placeholder_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_scroll_bar_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_button_component.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_header_component.dart';
import 'package:sendbird_uikit/src/internal/component/module/sbu_selectable_user_list_item_component.dart';
import 'package:sendbird_uikit/src/internal/provider/sbu_message_collection_provider.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

/// SBUGroupChannelInviteScreen
class SBUGroupChannelInviteScreen extends SBUStatefulComponent {
  final int messageCollectionNo;

  const SBUGroupChannelInviteScreen({
    required this.messageCollectionNo,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUGroupChannelInviteScreenState();
}

class SBUGroupChannelInviteScreenState
    extends State<SBUGroupChannelInviteScreen> {
  final scrollController = ScrollController();
  late ApplicationUserListQuery query;

  List<User> userList = [];
  List<String> selectedUserIdList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    final channel = SBUMessageCollectionProvider()
        .getCollection(widget.messageCollectionNo)
        ?.channel;

    if (channel != null) {
      query = ApplicationUserListQuery();
      _next(channel);
    }
  }

  void _next(GroupChannel channel) {
    runZonedGuarded(() {
      query.next().then((users) {
        if (mounted) {
          setState(() {
            for (final user in users) {
              if (channel.members
                      .any((member) => member.userId == user.userId) ==
                  false) {
                isLoading = false;
                userList.add(user);
              }
            }
          });

          // Check if no scrollbar
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (userList.isNotEmpty) {
              if (scrollController.position.maxScrollExtent == 0) {
                if (!query.isLoading && query.hasNext) {
                  _next(channel);
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
        text: strings.inviteMembers,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: true,
      textButton: SBUTextButtonComponent(
        height: 32,
        text: SBUTextComponent(
          text:
              '${strings.invite}${selectedUserIdList.isNotEmpty ? ' (${selectedUserIdList.length})' : ''}',
          textType: SBUTextType.button,
          textColorType: selectedUserIdList.isNotEmpty
              ? SBUTextColorType.primary
              : SBUTextColorType.disabled,
        ),
        onButtonClicked: selectedUserIdList.isNotEmpty
            ? () async {
                Navigator.pop(context);
                await channel?.invite(selectedUserIdList);
              }
            : null,
        padding: const EdgeInsets.all(8),
      ),
    );

    final list = NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
          if (!query.isLoading && query.hasNext) {
            if (channel != null) {
              _next(channel);
            }
          }
        }
        return false;
      },
      child: SBUScrollBarComponent(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          itemCount: userList.length,
          itemBuilder: (context, i) {
            return SBUSelectableUserListItemComponent(
              width: double.maxFinite,
              height: 56,
              backgroundColor: isLightTheme
                  ? SBUColors.background50
                  : SBUColors.background600,
              isChecked: selectedUserIdList.firstWhereOrNull(
                      (userId) => userList[i].userId == userId) !=
                  null,
              user: userList[i],
              onListItemCheckChanged: (isChecked, user) {
                setState(() {
                  if (isChecked) {
                    selectedUserIdList.add(user.userId);
                  } else {
                    selectedUserIdList.remove(user.userId);
                  }
                });
              },
            );
          },
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Expanded(
          child: Container(
            color:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
            child: userList.isNotEmpty
                ? list
                : widget.getDefaultContainer(
                    isLightTheme,
                    child: isLoading
                        ? Container()
                        : SBUPlaceholderComponent(
                            isLightTheme: isLightTheme,
                            iconData: SBUIcons.members,
                            text: strings.thereAreNoUsers,
                          ),
                  ),
          ),
        ),
      ],
    );
  }
}

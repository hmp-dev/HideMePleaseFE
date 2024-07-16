// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

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

/// SBUGroupChannelOperatorsScreen
class SBUGroupChannelOperatorsScreen extends SBUStatefulComponent {
  final int messageCollectionNo;

  const SBUGroupChannelOperatorsScreen({
    required this.messageCollectionNo,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SBUGroupChannelOperatorsScreenState();
}

class SBUGroupChannelOperatorsScreenState
    extends State<SBUGroupChannelOperatorsScreen> {
  final scrollController = ScrollController();

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
        text: strings.operators,
        textType: SBUTextType.heading1,
        textColorType: SBUTextColorType.text01,
      ),
      hasBackKey: true,
    );

    final sortedMembers =
        channel != null ? widget.sortMembersByNickname(channel.members) : null;
    final operators =
        sortedMembers?.where((member) => member.role == Role.operator).toList();
    final myMember = widget.getMyMember(channel);

    return Column(
      children: [
        header,
        Expanded(
          child: Container(
            width: double.maxFinite,
            color:
                isLightTheme ? SBUColors.background50 : SBUColors.background600,
            child: channel != null && operators != null && operators.isNotEmpty
                ? SBUScrollBarComponent(
                    controller: scrollController,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: operators.length,
                      itemBuilder: (context, i) {
                        return SBUUserListItemComponent(
                          width: double.maxFinite,
                          height: 56,
                          backgroundColor: isLightTheme
                              ? SBUColors.background50
                              : SBUColors.background600,
                          channel: channel,
                          user: operators[i],
                          canOperate: myMember?.role == Role.operator,
                          moderationType: SBUModerationType.operators,
                        );
                      },
                    ),
                  )
                : widget.getDefaultContainer(
                    isLightTheme,
                    child: SBUPlaceholderComponent(
                      isLightTheme: isLightTheme,
                      iconData: SBUIcons.members,
                      text: strings.thereAreNoMembers,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

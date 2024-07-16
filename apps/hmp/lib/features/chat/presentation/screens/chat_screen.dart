import 'package:flutter/material.dart';
import 'package:mobile/features/chat/presentation/screens/chat_user_detail_popup_screen.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

class CommunityChatScreen extends StatelessWidget {
  final String channel;
  const CommunityChatScreen({super.key, required this.channel});

  static push(BuildContext context, {required String channel}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityChatScreen(channel: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelScreen(
          channelUrl: channel,
          onOtherUserProfileTapped: (message) {
            if (message.sender != null) {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                builder: (context) {
                  return ChatUserDetailPopupScreen(
                    userId: message.sender!.userId,
                    userNickname: message.sender!.nickname,
                    userProfileImg: message.sender!.profileUrl,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class TestChatListScreen extends StatelessWidget {
  const TestChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SBUGroupChannelListScreen(
          onCreateButtonClicked: () {
            moveToGroupChannelCreateScreen(context);
          },
          onListItemClicked: (channel) {
            moveToGroupChannelScreen(context, channel.channelUrl);
          },
        ),
      ),
    );
  }

  void moveToGroupChannelCreateScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelCreateScreen(
            onChannelCreated: (channel) {
              moveToGroupChannelScreen(context, channel.channelUrl);
            },
          ),
        ),
      ),
    ));
  }

  void moveToGroupChannelScreen(BuildContext context, String channelUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        body: SafeArea(
          child: SBUGroupChannelScreen(
            channelUrl: channelUrl,
          ),
        ),
      ),
    ));
  }
}

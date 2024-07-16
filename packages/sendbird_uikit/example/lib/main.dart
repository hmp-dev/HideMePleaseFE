// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SendbirdUIKit.init(appId: 'YOUR_APP_ID');
  await SendbirdUIKit.connect('YOUR_USER_ID');

  runApp(SendbirdUIKit.provider(
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

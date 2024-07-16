// Copyright (c) 2024 Sendbird, Inc. All rights reserved.

import 'package:flutter/widgets.dart';

/// SBUStringProvider
class SBUStringProvider with ChangeNotifier {
  SBUStrings _strings = SBUStrings.defaultStrings;

  SBUStringProvider._();

  static final SBUStringProvider _provider = SBUStringProvider._();

  factory SBUStringProvider() => _provider;

  /// Sets strings.
  void setStrings(SBUStrings strings) {
    _strings = strings;
    notifyListeners();
  }

  /// Gets strings.
  SBUStrings get strings => _strings;
}

/// SBUStrings
class SBUStrings {
  // GroupChannel list
  String channels;
  String yesterday;
  String turnPushNotificationOff;
  String turnPushNotificationOn;
  String leaveChannel;
  String noMembers;
  String Function(String user) isTyping;
  String Function(String userA, String userB) areTyping;
  String severalPeopleAreTyping;
  String noChannels;
  String somethingWentWrong;

  // GroupChannel settings
  String settings;
  String changeNickname;
  String changeProfileImage;
  String darkTheme;
  String pushNotifications;
  String doNotDisturb;
  String exitToHome;

  // GroupChannel create
  String newChannel;
  String create;
  String thereAreNoUsers;

  // GroupChannel
  String enterMessage;
  String takePhoto;
  String takeVideo;
  String gallery;
  String document;
  String copy;
  String edit;
  String delete;
  String retry;
  String remove;
  String channelIsFrozen;
  String chatIsUnavailableInThisChannel;
  String youAreMuted;
  String noName;
  String save;
  String deleteMessage;
  String cancel;
  String edited;
  String message;
  String userId;
  String noMessages;
  String fileSaved;
  String Function(String uploadSizeLimit) theMaximumSizePerFileIsMB;

  // GroupChannel information
  String channelInformation;
  String moderations;
  String notifications;
  String members;
  String changeChannelName;
  String changeChannelImage;
  String choosePhoto;
  String enterName;

  // GroupChannel moderations
  String operators;
  String mutedMembers;
  String bannedUsers;
  String freezeChannel;
  String unban;
  String noMutedMembers;
  String noBannedUsers;

  // GroupChannel members
  String you;
  String operator;
  String registerAsOperator;
  String unregisterOperator;
  String mute;
  String unmute;
  String ban;
  String thereAreNoMembers;

  // GroupChannel invite
  String inviteMembers;
  String invite;

  SBUStrings({
    // GroupChannel list
    required this.channels,
    required this.yesterday,
    required this.turnPushNotificationOff,
    required this.turnPushNotificationOn,
    required this.leaveChannel,
    required this.noMembers,
    required this.isTyping,
    required this.areTyping,
    required this.severalPeopleAreTyping,
    required this.noChannels,
    required this.somethingWentWrong,

    // GroupChannel settings
    required this.settings,
    required this.changeNickname,
    required this.changeProfileImage,
    required this.darkTheme,
    required this.pushNotifications,
    required this.doNotDisturb,
    required this.exitToHome,

    // GroupChannel create
    required this.newChannel,
    required this.create,
    required this.thereAreNoUsers,

    // GroupChannel
    required this.enterMessage,
    required this.takePhoto,
    required this.takeVideo,
    required this.gallery,
    required this.document,
    required this.copy,
    required this.edit,
    required this.delete,
    required this.retry,
    required this.remove,
    required this.channelIsFrozen,
    required this.chatIsUnavailableInThisChannel,
    required this.youAreMuted,
    required this.noName,
    required this.save,
    required this.deleteMessage,
    required this.cancel,
    required this.edited,
    required this.message,
    required this.userId,
    required this.noMessages,
    required this.fileSaved,
    required this.theMaximumSizePerFileIsMB,

    // GroupChannel information
    required this.channelInformation,
    required this.moderations,
    required this.notifications,
    required this.members,
    required this.changeChannelName,
    required this.changeChannelImage,
    required this.choosePhoto,
    required this.enterName,

    // GroupChannel moderations
    required this.operators,
    required this.mutedMembers,
    required this.bannedUsers,
    required this.freezeChannel,
    required this.unban,
    required this.noMutedMembers,
    required this.noBannedUsers,

    // GroupChannel members
    required this.you,
    required this.operator,
    required this.registerAsOperator,
    required this.unregisterOperator,
    required this.mute,
    required this.unmute,
    required this.ban,
    required this.thereAreNoMembers,

    // GroupChannel invite
    required this.inviteMembers,
    required this.invite,
  });

  static SBUStrings defaultStrings = SBUStrings(
    // GroupChannel list
    channels: 'Channels',
    yesterday: 'Yesterday',
    turnPushNotificationOff: 'Turn push notification off',
    turnPushNotificationOn: 'Turn push notification on',
    leaveChannel: 'Leave channel',
    noMembers: '(No members)',
    isTyping: (user) => '$user is typing…',
    areTyping: (userA, userB) => '$userA and $userB are typing…',
    severalPeopleAreTyping: 'Several people are typing…',
    noChannels: 'No channels',
    somethingWentWrong: 'Something went wrong',

    // GroupChannel settings
    settings: 'Settings',
    changeNickname: 'Change nickname',
    changeProfileImage: 'Change profile image',
    darkTheme: 'Dark theme',
    pushNotifications: 'Push notifications',
    doNotDisturb: 'Do not disturb',
    exitToHome: 'Exit to home',

    // GroupChannel create
    newChannel: 'New channel',
    create: 'Create',
    thereAreNoUsers: 'There are no users',

    // GroupChannel
    enterMessage: 'Enter message',
    takePhoto: 'Take photo',
    takeVideo: 'Take video',
    gallery: 'Gallery',
    document: 'Document',
    copy: 'Copy',
    edit: 'Edit',
    delete: 'Delete',
    retry: 'Retry',
    remove: 'Remove',
    channelIsFrozen: 'Channel is frozen',
    chatIsUnavailableInThisChannel: 'Channel is unavailable in this channel',
    youAreMuted: 'You are muted',
    noName: '(No name)',
    save: 'Save',
    deleteMessage: 'Delete message?',
    cancel: 'Cancel',
    edited: '(edited)',
    message: 'Message',
    userId: 'User ID',
    noMessages: 'No messages',
    fileSaved: 'File saved',
    theMaximumSizePerFileIsMB: (uploadSizeLimit) =>
        'The maximum size per file is $uploadSizeLimit MB',

    // GroupChannel information
    channelInformation: 'Channel information',
    moderations: 'Moderations',
    notifications: 'Notifications',
    members: 'Members',
    changeChannelName: 'Change channel name',
    changeChannelImage: 'Change channel image',
    choosePhoto: 'Choose photo',
    enterName: 'Enter name',

    // GroupChannel moderations
    operators: 'Operators',
    mutedMembers: 'Muted members',
    bannedUsers: 'Banned users',
    freezeChannel: 'Freeze channel',
    unban: 'Unban',
    noMutedMembers: 'No muted members',
    noBannedUsers: 'No banned users',

    // GroupChannel members
    you: '(You)',
    operator: 'Operator',
    registerAsOperator: 'Register as operator',
    unregisterOperator: 'Unregister operator',
    mute: 'Mute',
    unmute: 'Unmute',
    ban: 'Ban',
    thereAreNoMembers: 'There are no members',

    // GroupChannel invite
    inviteMembers: 'Invite members',
    invite: 'Invite',
  );
}

import 'dart:io';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

final List<Map<String, dynamic>> sdkConfigs = [
  {
    'name': 'sample app',
    'appId': 'd410836424c7fd52e2bfd5eaa1560b4e', // 'wepin-app-id',
    'appKey':
        'ak_live_OvIn9KoWHQjXOlKyTW3tyPtvSWZUOGfpBy0VkY5Xz09', //'wepin-app-key-android',
    'privateKey': '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',
    'provider': 'google',
    "gooleClientId":
        '307052986452-mtcr3l78gdu8e9d77plmuk6tgn1hiicd.apps.googleusercontent.com',
    'loginProviders': [
      LoginProvider(
          provider: 'google',
          clientId:
              '307052986452-mtcr3l78gdu8e9d77plmuk6tgn1hiicd.apps.googleusercontent.com'), //'google-client-id'
      LoginProvider(provider: 'apple', clientId: 'ios-client-id'),
      LoginProvider(provider: 'discord', clientId: 'discord-client-id'),
      LoginProvider(provider: 'naver', clientId: 'naver-client-id'),
      LoginProvider(provider: 'kakao', clientId: 'kakao-client-id'),
    ]
  },
];

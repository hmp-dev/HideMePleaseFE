import 'dart:io';
import 'package:wepin_flutter_widget_sdk/wepin_flutter_widget_sdk_type.dart';

final List<Map<String, dynamic>> sdkConfigs = [
  {
    'name': 'sample app',
    'appId': 'wepin-app-id',
    'appKey': Platform.isIOS ? 'wepin-app-key-ios': 'wepin-app-key-android',
    'privateKey': 'wepin-oauth-private-key',
    'loginProviders':[
      LoginProvider(provider: 'google', clientId: 'google-client-id'),
      LoginProvider(provider: 'apple', clientId: 'ios-client-id'),
      LoginProvider(provider: 'discord', clientId: 'discord-client-id'),
      LoginProvider(provider: 'naver', clientId: 'naver-client-id'),
    ]
  },
];
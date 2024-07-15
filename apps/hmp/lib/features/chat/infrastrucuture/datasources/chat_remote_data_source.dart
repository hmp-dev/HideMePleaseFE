import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

@lazySingleton
class ChatRemoteDataSource {
  ChatRemoteDataSource();

  Future<void> init({
    required String userId,
    required String appId,
    String? accessToken,
  }) async {
    await Future.wait([
      SendbirdUIKit.init(
        appId: appId,
        theme: SBUTheme.dark,
      ),
      SendbirdChat.init(
        appId: appId,
        options: SendbirdChatOptions(useCollectionCaching: true),
      ),
    ]);

    await Future.wait([
      SendbirdUIKit.connect(userId, accessToken: accessToken),
      SendbirdChat.connect(userId, accessToken: accessToken)
    ]);
  }

  Future<List<GroupChannel>> getChannelList(
      {required List<String> channelUrls}) async {
    final query = GroupChannelListQuery()
      ..includeEmpty = true // The default value is true.
      ..order = GroupChannelListQueryOrder
          .chronological // Acceptable values are chronological, latestLastMessage(default), channelNameAlphabetical and metadataValueAlphabetical.
      ..publicChannelFilter = PublicChannelFilter.public
      ..channelUrlsFilter = channelUrls; // Retrieve public group channels.

    return await query.next();
  }

  Future<List<BaseMessage>> getMessages({
    required ChannelType channelType,
    required String channelUrl,
    required int limit,
  }) async {
    final query = PreviousMessageListQuery(
      channelType: channelType,
      channelUrl: channelUrl,
    )
      ..limit = limit
      ..customTypesFilter = []
      ..senderIdsFilter = []
      ..messageTypeFilter = MessageTypeFilter.all;

    return await query.next();
  }
}

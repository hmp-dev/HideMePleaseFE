import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

abstract class ChatRepository {
  Future<Either<HMPError, Unit>> init({
    required String userId,
    required String appId,
    String? accessToken,
  });

  Future<Either<HMPError, List<GroupChannel>>> getChannelList(
      {required List<String> channelUrls});

  Future<Either<HMPError, List<BaseMessage>>> getMessages({
    required ChannelType channelType,
    required String channelUrl,
    int limit = 3,
  });
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/chat/infrastrucuture/datasources/chat_remote_data_source.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<HMPError, Unit>> init({
    required String userId,
    required String appId,
    String? accessToken,
  }) async {
    try {
      await _remoteDataSource.init(
          userId: userId, appId: appId, accessToken: accessToken);
      return right(unit);
    } on SendbirdException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<GroupChannel>>> getChannelList(
      {required List<String> channelUrls}) async {
    try {
      final channels = await _remoteDataSource.getChannelList(
        channelUrls: channelUrls,
      );
      return right(channels);
    } on SendbirdException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<BaseMessage>>> getMessages({
    required ChannelType channelType,
    required String channelUrl,
    int limit = 3,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        channelType: channelType,
        channelUrl: channelUrl,
        limit: limit,
      );
      return right(messages);
    } on SendbirdException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}

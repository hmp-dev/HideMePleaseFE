import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';

@lazySingleton
class ChatRemoteDataSource {
  final Network _network;

  ChatRemoteDataSource(this._network);

  Future<void> init({
    required String userId,
    required String appId,
    String? accessToken,
  }) async {
    await SendbirdUIKit.init(
      appId: appId,
      theme: SBUTheme.dark,
    );
    await SendbirdUIKit.connect(userId, accessToken: accessToken);
  }
}

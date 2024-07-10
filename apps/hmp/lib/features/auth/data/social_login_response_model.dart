import 'package:equatable/equatable.dart';

class SocialLoginResponseModel extends Equatable {
  final String accessToken;

  final String platform;

  const SocialLoginResponseModel({
    required this.accessToken,
    required this.platform,
  });

  @override
  List<Object?> get props {
    return [
      accessToken,
      platform,
    ];
  }

  @override
  String toString() {
    return 'SocialLoginResponseModel(accessToken: $accessToken, platform: $platform)';
  }
}

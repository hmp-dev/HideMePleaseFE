class UpdateProfileRequestDto {
  final String? nickName;
  final String? introduction;
  final bool? locationPublic;
  final bool? notificationsEnabled;
  final String? pfpNftId;
  final String? fcmToken;
  final String? profilePartsString;
  final String? finalProfileImageUrl;
  final bool? onboardingCompleted;
  final String? appOS;
  final String? appVersion;

  UpdateProfileRequestDto({
    this.nickName,
    this.introduction,
    this.locationPublic,
    this.notificationsEnabled,
    this.pfpNftId,
    this.fcmToken,
    this.profilePartsString,
    this.finalProfileImageUrl,
    this.onboardingCompleted,
    this.appOS,
    this.appVersion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nickName': nickName,
      'introduction': introduction,
      'locationPublic': locationPublic,
      'notificationsEnabled': notificationsEnabled,
      'pfpNftId': pfpNftId,
      'fcmToken': fcmToken,
      'profilePartsString': profilePartsString,
      'finalProfileImageUrl': finalProfileImageUrl,
      'onboardingCompleted': onboardingCompleted,
      'appOS': appOS,
      'appVersion': appVersion,
    };
    // Remove entries with null values
    json.removeWhere((_, value) => value == null);

    return json;
  }
}

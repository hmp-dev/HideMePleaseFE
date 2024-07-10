class UpdateProfileRequestDto {
  final String? nickName;
  final String? introduction;
  final bool? locationPublic;
  final bool? notificationsEnabled;
  final String? pfpNftId;
  final String? fcmToken;

  UpdateProfileRequestDto({
    this.nickName,
    this.introduction,
    this.locationPublic,
    this.notificationsEnabled,
    this.pfpNftId,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nickName': nickName,
      'introduction': introduction,
      'locationPublic': locationPublic,
      'notificationsEnabled': notificationsEnabled,
      'pfpNftId': pfpNftId,
      'fcmToken': fcmToken
    };
    // Remove entries with null values
    json.removeWhere((_, value) => value == null);

    return json;
  }
}

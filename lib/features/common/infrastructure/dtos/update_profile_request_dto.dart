class UpdateProfileRequestDto {
  final String? nickName;
  final String? introduction;
  final bool? locationPublic;
  final String? pfpNftId;

  UpdateProfileRequestDto({
    this.nickName,
    this.introduction,
    this.locationPublic,
    this.pfpNftId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nickName': nickName,
      'introduction': introduction,
      'locationPublic': locationPublic,
      'pfpNftId': pfpNftId,
    };
    // Remove entries with null values
    json.removeWhere((_, value) => value == null);

    return json;
  }
}

import 'dart:convert';

/// Character profile model for NFT-style layered character system
class CharacterProfile {
  final String gender; // 'male' or 'female'
  final String background;
  final String body;
  final String clothes;
  final String? earAccessory;
  final String eyes;
  final String hair;
  final String nose;

  CharacterProfile({
    required this.gender,
    required this.background,
    required this.body,
    required this.clothes,
    this.earAccessory,
    required this.eyes,
    required this.hair,
    required this.nose,
  });

  /// Generate unique ID for this character combination
  String get id => '${gender}_${body.split('/').last}_${clothes.split('/').last}_${eyes.split('/').last}_${hair.split('/').last}';

  /// Get display name for the character
  String get displayName => 'Character ${hashCode.toString().substring(0, 4)}';

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'gender': gender,
    'background': background,
    'body': body,
    'clothes': clothes,
    'earAccessory': earAccessory,
    'eyes': eyes,
    'hair': hair,
    'nose': nose,
  };

  /// Convert to JSON string for server storage
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON
  factory CharacterProfile.fromJson(Map<String, dynamic> json) => CharacterProfile(
    gender: json['gender'],
    background: json['background'],
    body: json['body'],
    clothes: json['clothes'],
    earAccessory: json['earAccessory'],
    eyes: json['eyes'],
    hair: json['hair'],
    nose: json['nose'],
  );
}
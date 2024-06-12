import 'package:equatable/equatable.dart';

class CommunityMemberEntity extends Equatable {
  final int totalPoints;
  final int pointFluctuation;
  final int memberRank;
  final String name;
  final String userId;
  final String introduction;
  final String pfpImage;

  const CommunityMemberEntity({
    required this.totalPoints,
    required this.pointFluctuation,
    required this.memberRank,
    required this.name,
    required this.userId,
    required this.introduction,
    required this.pfpImage,
  });

  const CommunityMemberEntity.empty()
      : totalPoints = 0,
        pointFluctuation = 0,
        memberRank = 0,
        name = '',
        userId = '',
        introduction = '',
        pfpImage = '';

  @override
  List<Object?> get props {
    return [
      totalPoints,
      pointFluctuation,
      memberRank,
      name,
      userId,
      introduction,
      pfpImage,
    ];
  }

  CommunityMemberEntity copyWith({
    int? totalPoints,
    int? pointFluctuation,
    int? memberRank,
    String? name,
    String? userId,
    String? introduction,
    String? pfpImage,
  }) {
    return CommunityMemberEntity(
      totalPoints: totalPoints ?? this.totalPoints,
      pointFluctuation: pointFluctuation ?? this.pointFluctuation,
      memberRank: memberRank ?? this.memberRank,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      introduction: introduction ?? this.introduction,
      pfpImage: pfpImage ?? this.pfpImage,
    );
  }
}

part of 'community_details_cubit.dart';

class CommunityDetailsState extends BaseState {
  final TopCollectionNftEntity nftInfo;
  final NftNetworkEntity nftNetworkInfo;
  final int benefitCount;
  final List<BenefitEntity> nftBenefits;
  final int membersCount;
  final List<CommunityMemberEntity> communityMembers;
  @override
  final RequestStatus status;
  final RequestStatus membersStatus;

  const CommunityDetailsState({
    required this.status,
    required this.membersStatus,
    required this.nftInfo,
    required this.nftNetworkInfo,
    required this.benefitCount,
    required this.nftBenefits,
    required this.membersCount,
    required this.communityMembers,
  });

  factory CommunityDetailsState.initial() => const CommunityDetailsState(
        status: RequestStatus.initial,
        membersStatus: RequestStatus.initial,
        nftInfo: TopCollectionNftEntity.empty(),
        nftNetworkInfo: NftNetworkEntity.empty(),
        benefitCount: 0,
        nftBenefits: [],
        membersCount: 0,
        communityMembers: [],
      );

  bool get isMembersLoading =>
      membersStatus == RequestStatus.initial ||
      membersStatus == RequestStatus.loading;

  bool get isMembersSuccess => membersStatus == RequestStatus.success;

  bool get isMembersError => membersStatus == RequestStatus.failure;

  @override
  List<Object?> get props => [
        status,
        membersStatus,
        nftInfo,
        nftNetworkInfo,
        benefitCount,
        nftBenefits,
        membersCount,
        communityMembers,
      ];

  @override
  CommunityDetailsState copyWith({
    TopCollectionNftEntity? nftInfo,
    NftNetworkEntity? nftNetworkInfo,
    int? benefitCount,
    List<BenefitEntity>? nftBenefits,
    int? membersCount,
    List<CommunityMemberEntity>? communityMembers,
    RequestStatus? status,
    RequestStatus? membersStatus,
  }) {
    return CommunityDetailsState(
      nftInfo: nftInfo ?? this.nftInfo,
      nftNetworkInfo: nftNetworkInfo ?? this.nftNetworkInfo,
      benefitCount: benefitCount ?? this.benefitCount,
      nftBenefits: nftBenefits ?? this.nftBenefits,
      membersCount: membersCount ?? this.membersCount,
      communityMembers: communityMembers ?? this.communityMembers,
      status: status ?? this.status,
      membersStatus: membersStatus ?? this.membersStatus,
    );
  }

  @override
  String toString() {
    return 'CommunityDetailsState(nftInfo: $nftInfo, nftNetworkInfo: $nftNetworkInfo, benefitCount: $benefitCount, nftBenefits: $nftBenefits, membersCount: $membersCount, communityMembers: $communityMembers, status: $status, membersStatus: $membersStatus)';
  }
}

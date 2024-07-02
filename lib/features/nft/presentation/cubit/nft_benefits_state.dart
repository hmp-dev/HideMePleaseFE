part of 'nft_benefits_cubit.dart';

class NftBenefitsState extends BaseState {
  final String errorMessage;
  final int totalBenefitCount;
  final List<BenefitEntity> nftBenefitList;
  final String selectedTokenAddress;
  final bool isAllBenefitsLoaded;
  final RequestStatus loadingMoreStatus;
  final int nftBenefitsPage;

  @override
  final RequestStatus submitStatus;

  const NftBenefitsState({
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.totalBenefitCount,
    required this.nftBenefitList,
    required this.selectedTokenAddress,
    required this.isAllBenefitsLoaded,
    required this.loadingMoreStatus,
    required this.nftBenefitsPage,
  });

  factory NftBenefitsState.initial() => const NftBenefitsState(
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedTokenAddress: "",
        totalBenefitCount: 0,
        nftBenefitList: [],
        isAllBenefitsLoaded: false,
        loadingMoreStatus: RequestStatus.initial,
        nftBenefitsPage: 1,
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        selectedTokenAddress,
        totalBenefitCount,
        nftBenefitList,
        isAllBenefitsLoaded,
        loadingMoreStatus,
        nftBenefitsPage,
      ];

  @override
  NftBenefitsState copyWith({
    RequestStatus? submitStatus,
    String? errorMessage,
    int? totalBenefitCount,
    List<BenefitEntity>? nftBenefitList,
    String? selectedTokenAddress,
    bool? isAllBenefitsLoaded,
    RequestStatus? loadingMoreStatus,
    int? nftBenefitsPage,
  }) {
    return NftBenefitsState(
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      totalBenefitCount: totalBenefitCount ?? this.totalBenefitCount,
      nftBenefitList: nftBenefitList ?? this.nftBenefitList,
      selectedTokenAddress: selectedTokenAddress ?? this.selectedTokenAddress,
      isAllBenefitsLoaded: isAllBenefitsLoaded ?? this.isAllBenefitsLoaded,
      loadingMoreStatus: loadingMoreStatus ?? this.loadingMoreStatus,
      nftBenefitsPage: nftBenefitsPage ?? this.nftBenefitsPage,
    );
  }
}

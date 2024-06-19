part of 'nft_benefits_cubit.dart';

class NftBenefitsState extends BaseState {
  final String errorMessage;
  final List<BenefitEntity> nftBenefitList;
  final String selectedTokenAddress;

  @override
  final RequestStatus submitStatus;

  const NftBenefitsState({
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.nftBenefitList,
    required this.selectedTokenAddress,
  });

  factory NftBenefitsState.initial() => const NftBenefitsState(
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedTokenAddress: "",
        nftBenefitList: [],
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        selectedTokenAddress,
        nftBenefitList,
      ];

  @override
  NftBenefitsState copyWith({
    RequestStatus? submitStatus,
    String? errorMessage,
    List<BenefitEntity>? nftBenefitList,
    String? selectedTokenAddress,
  }) {
    return NftBenefitsState(
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      nftBenefitList: nftBenefitList ?? this.nftBenefitList,
      selectedTokenAddress: selectedTokenAddress ?? this.selectedTokenAddress,
    );
  }
}

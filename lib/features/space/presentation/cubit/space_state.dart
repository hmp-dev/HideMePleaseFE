part of 'space_cubit.dart';

class SpaceState extends BaseState {
  final String errorMessage;
  final SpacesResponseEntity spacesResponseEntity;
  final String selectedNftTokenAddress;
  final String nfcToken;
  final bool benefitRedeemStatus;

  @override
  final RequestStatus submitStatus;

  const SpaceState({
    this.submitStatus = RequestStatus.initial,
    required this.spacesResponseEntity,
    required this.errorMessage,
    required this.selectedNftTokenAddress,
    required this.nfcToken,
    required this.benefitRedeemStatus,
  });

  factory SpaceState.initial() => SpaceState(
        submitStatus: RequestStatus.initial,
        spacesResponseEntity: SpacesResponseEntity.empty(),
        errorMessage: "",
        selectedNftTokenAddress: "",
        nfcToken: "",
        benefitRedeemStatus: false,
      );

  @override
  List<Object?> get props => [
        submitStatus,
        spacesResponseEntity,
        errorMessage,
        selectedNftTokenAddress,
        nfcToken,
        benefitRedeemStatus,
      ];

  @override
  SpaceState copyWith({
    RequestStatus? submitStatus,
    SpacesResponseEntity? spacesResponseEntity,
    String? errorMessage,
    String? selectedNftTokenAddress,
    String? nfcToken,
    bool? benefitRedeemStatus,
  }) {
    return SpaceState(
      submitStatus: submitStatus ?? this.submitStatus,
      spacesResponseEntity: spacesResponseEntity ?? this.spacesResponseEntity,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedNftTokenAddress:
          selectedNftTokenAddress ?? this.selectedNftTokenAddress,
      nfcToken: nfcToken ?? this.nfcToken,
      benefitRedeemStatus: benefitRedeemStatus ?? this.benefitRedeemStatus,
    );
  }
}

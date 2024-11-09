part of 'nearby_spaces_cubit.dart';

class NearBySpacesState extends BaseState {
  final String errorMessage;
  final SpacesResponseEntity spacesResponseEntity;
  final BenefitEntity selectedBenefitEntity;
  final SpaceDetailEntity selectedSpaceDetailEntity;
  final bool isNavigatedToBenefitScreen;

  @override
  final RequestStatus submitStatus;

  const NearBySpacesState({
    this.submitStatus = RequestStatus.initial,
    required this.spacesResponseEntity,
    required this.errorMessage,
    required this.selectedBenefitEntity,
    required this.selectedSpaceDetailEntity,
    required this.isNavigatedToBenefitScreen,
  });

  factory NearBySpacesState.initial() => NearBySpacesState(
      submitStatus: RequestStatus.initial,
      spacesResponseEntity: SpacesResponseEntity.empty(),
      errorMessage: "",
      selectedBenefitEntity: const BenefitEntity.empty(),
      selectedSpaceDetailEntity: const SpaceDetailEntity.empty(),
      isNavigatedToBenefitScreen: false);

  @override
  List<Object?> get props => [
        submitStatus,
        spacesResponseEntity,
        errorMessage,
        selectedBenefitEntity,
        selectedSpaceDetailEntity,
        isNavigatedToBenefitScreen
      ];

  @override
  NearBySpacesState copyWith(
      {RequestStatus? submitStatus,
      SpacesResponseEntity? spacesResponseEntity,
      BenefitEntity? selectedBenefitEntity,
      String? errorMessage,
      SpaceDetailEntity? selectedSpaceDetailEntity,
      bool? isNavigatedToBenefitScreen}) {
    return NearBySpacesState(
        submitStatus: submitStatus ?? this.submitStatus,
        spacesResponseEntity: spacesResponseEntity ?? this.spacesResponseEntity,
        errorMessage: errorMessage ?? this.errorMessage,
        selectedBenefitEntity:
            selectedBenefitEntity ?? this.selectedBenefitEntity,
        selectedSpaceDetailEntity:
            selectedSpaceDetailEntity ?? this.selectedSpaceDetailEntity,
        isNavigatedToBenefitScreen:
            isNavigatedToBenefitScreen ?? this.isNavigatedToBenefitScreen);
  }
}

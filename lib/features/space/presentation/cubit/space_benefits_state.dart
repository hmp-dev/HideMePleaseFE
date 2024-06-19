part of 'space_benefits_cubit.dart';

class SpaceBenefitsState extends BaseState {
  final String errorMessage;
  final BenefitsGroupEntity benefitGroupEntity;
  final String selectedSpaceId;

  @override
  final RequestStatus submitStatus;

  const SpaceBenefitsState({
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.benefitGroupEntity,
    required this.selectedSpaceId,
  });

  factory SpaceBenefitsState.initial() => SpaceBenefitsState(
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        selectedSpaceId: "",
        benefitGroupEntity: BenefitsGroupEntity.empty(),
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        selectedSpaceId,
        benefitGroupEntity,
      ];

  @override
  SpaceBenefitsState copyWith({
    RequestStatus? submitStatus,
    String? errorMessage,
    BenefitsGroupEntity? benefitGroupEntity,
    String? selectedSpaceId,
  }) {
    return SpaceBenefitsState(
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      benefitGroupEntity: benefitGroupEntity ?? this.benefitGroupEntity,
      selectedSpaceId: selectedSpaceId ?? this.selectedSpaceId,
    );
  }
}

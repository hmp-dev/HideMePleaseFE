part of 'space_detail_cubit.dart';

class SpaceDetailState extends BaseState {
  final String errorMessage;
  final SpaceDetailEntity spaceDetailEntity;
  final BenefitEntity selectedBenefitEntity;

  @override
  final RequestStatus submitStatus;

  const SpaceDetailState(
      {this.submitStatus = RequestStatus.initial,
      required this.errorMessage,
      required this.spaceDetailEntity,
      required this.selectedBenefitEntity});

  factory SpaceDetailState.initial() => const SpaceDetailState(
      submitStatus: RequestStatus.initial,
      errorMessage: "",
      spaceDetailEntity: SpaceDetailEntity.empty(),
      selectedBenefitEntity: BenefitEntity.empty());

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
        spaceDetailEntity,
        selectedBenefitEntity,
      ];

  @override
  SpaceDetailState copyWith(
      {String? errorMessage,
      RequestStatus? submitStatus,
      bool? benefitRedeemStatus,
      SpaceDetailEntity? spaceDetailEntity,
      BenefitEntity? selectedBenefitEntity}) {
    return SpaceDetailState(
      errorMessage: errorMessage ?? this.errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
      spaceDetailEntity: spaceDetailEntity ?? this.spaceDetailEntity,
      selectedBenefitEntity:
          selectedBenefitEntity ?? this.selectedBenefitEntity,
    );
  }
}

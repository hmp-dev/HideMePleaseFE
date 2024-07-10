part of 'benefit_redeem_cubit.dart';

class BenefitRedeemState extends BaseState {
  final String errorMessage;
  final bool benefitRedeemStatus;

  @override
  final RequestStatus submitStatus;

  const BenefitRedeemState({
    this.submitStatus = RequestStatus.initial,
    required this.errorMessage,
    required this.benefitRedeemStatus,
  });

  factory BenefitRedeemState.initial() => const BenefitRedeemState(
        submitStatus: RequestStatus.initial,
        errorMessage: "",
        benefitRedeemStatus: false,
      );

  @override
  List<Object?> get props => [
        submitStatus,
        errorMessage,
      ];

  @override
  BenefitRedeemState copyWith({
    String? errorMessage,
    RequestStatus? submitStatus,
    bool? benefitRedeemStatus,
  }) {
    return BenefitRedeemState(
      errorMessage: errorMessage ?? this.errorMessage,
      submitStatus: submitStatus ?? this.submitStatus,
      benefitRedeemStatus: benefitRedeemStatus ?? this.benefitRedeemStatus,
    );
  }
}

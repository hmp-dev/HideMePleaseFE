part of 'model_banner_cubit.dart';

class ModelBannerState extends BaseState {
  final ModelBannerEntity modelBannerEntity;
  final String errorMessage;

  @override
  final RequestStatus submitStatus;

  const ModelBannerState({
    required this.modelBannerEntity,
    required this.errorMessage,
    this.submitStatus = RequestStatus.initial,
  });

  factory ModelBannerState.initial() => const ModelBannerState(
        modelBannerEntity: ModelBannerEntity.empty(),
        errorMessage: "",
      );

  @override
  List<Object?> get props => [
        modelBannerEntity,
        submitStatus,
        errorMessage,
      ];

  @override
  ModelBannerState copyWith({
    ModelBannerEntity? modelBannerEntity,
    RequestStatus? submitStatus,
    String? errorMessage,
  }) {
    return ModelBannerState(
      modelBannerEntity: modelBannerEntity ?? this.modelBannerEntity,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
   
    );
  }
}

part of 'enable_location_cubit.dart';

class EnableLocationState extends BaseState {
  final bool hasLocationPermission;
  final bool isLocationEnabled;
  final bool isAskToOpenLocationSettings;
  final int submitCount;

  @override
  final RequestStatus submitStatus;

  const EnableLocationState({
    required this.hasLocationPermission,
    required this.isLocationEnabled,
    required this.isAskToOpenLocationSettings,
    this.submitStatus = RequestStatus.initial,
    this.submitCount = 0,
  });

  factory EnableLocationState.initial() => const EnableLocationState(
        hasLocationPermission: false,
        isLocationEnabled: false,
        submitStatus: RequestStatus.initial,
        isAskToOpenLocationSettings: false,
        submitCount: 0,
      );

  @override
  List<Object?> get props => [
        hasLocationPermission,
        isLocationEnabled,
        submitStatus,
        isAskToOpenLocationSettings,
        submitCount,
      ];

  @override
  EnableLocationState copyWith({
    bool? hasLocationPermission,
    bool? isLocationEnabled,
    bool? isAskToOpenLocationSettings,
    RequestStatus? submitStatus,
    int? submitCount,
  }) {
    return EnableLocationState(
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      submitStatus: submitStatus ?? this.submitStatus,
      isAskToOpenLocationSettings:
          isAskToOpenLocationSettings ?? this.isAskToOpenLocationSettings,
      submitCount: submitCount ?? this.submitCount,
    );
  }
}

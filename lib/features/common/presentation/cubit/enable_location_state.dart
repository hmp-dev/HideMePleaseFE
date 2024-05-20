part of 'enable_location_cubit.dart';

class EnableLocationState extends BaseState {
  final bool hasLocationPermission;
  final bool isLocationEnabled;
  final bool isAskToOpenLocationSettings;
  final int submitCount;
  final double latitude;
  final double longitude;

  @override
  final RequestStatus submitStatus;

  const EnableLocationState({
    required this.hasLocationPermission,
    required this.isLocationEnabled,
    required this.isAskToOpenLocationSettings,
    required this.latitude,
    required this.longitude,
    this.submitStatus = RequestStatus.initial,
    this.submitCount = 0,
  });

  factory EnableLocationState.initial() => const EnableLocationState(
        hasLocationPermission: false,
        isLocationEnabled: false,
        submitStatus: RequestStatus.initial,
        isAskToOpenLocationSettings: false,
        submitCount: 0,
        latitude: 0.0,
        longitude: 0.0,
      );

  @override
  List<Object?> get props => [
        hasLocationPermission,
        isLocationEnabled,
        submitStatus,
        isAskToOpenLocationSettings,
        submitCount,
        latitude,
        longitude,
      ];

  @override
  EnableLocationState copyWith({
    bool? hasLocationPermission,
    bool? isLocationEnabled,
    bool? isAskToOpenLocationSettings,
    RequestStatus? submitStatus,
    int? submitCount,
    double? latitude,
    double? longitude,
  }) {
    return EnableLocationState(
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      submitStatus: submitStatus ?? this.submitStatus,
      isAskToOpenLocationSettings:
          isAskToOpenLocationSettings ?? this.isAskToOpenLocationSettings,
      submitCount: submitCount ?? this.submitCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

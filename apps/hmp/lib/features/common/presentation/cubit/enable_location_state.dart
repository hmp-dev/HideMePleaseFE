part of 'enable_location_cubit.dart';

class EnableLocationState extends BaseState {
  final bool hasLocationPermission;
  final bool isLocationEnabled;
  final bool isAskToOpenLocationSettings;
  final bool isLocationPermissionGranted;
  final bool isBackgroundLocationGranted;
  final int submitCount;
  final double latitude;
  final double longitude;
  final bool isLocationDenied;

  @override
  final RequestStatus submitStatus;
  final RequestStatus checkLocationPermsStatus;

  const EnableLocationState({
    required this.hasLocationPermission,
    required this.isLocationEnabled,
    required this.isAskToOpenLocationSettings,
    required this.isLocationPermissionGranted,
    required this.isBackgroundLocationGranted,
    required this.latitude,
    required this.longitude,
    required this.isLocationDenied,
    required this.checkLocationPermsStatus,
    this.submitStatus = RequestStatus.initial,
    this.submitCount = 0,
  });

  factory EnableLocationState.initial() => const EnableLocationState(
        hasLocationPermission: false,
        isLocationEnabled: false,
        submitStatus: RequestStatus.initial,
        checkLocationPermsStatus: RequestStatus.initial,
        isAskToOpenLocationSettings: false,
        isLocationPermissionGranted: false,
        isBackgroundLocationGranted: false,
        submitCount: 0,
        latitude: 0.0,
        longitude: 0.0,
        isLocationDenied: false,
      );

  @override
  List<Object?> get props => [
        hasLocationPermission,
        isLocationEnabled,
        submitStatus,
        checkLocationPermsStatus,
        isAskToOpenLocationSettings,
        isLocationPermissionGranted,
        isBackgroundLocationGranted,
        submitCount,
        latitude,
        longitude,
        isLocationDenied,
      ];

  @override
  EnableLocationState copyWith({
    bool? hasLocationPermission,
    bool? isLocationEnabled,
    bool? isAskToOpenLocationSettings,
    bool? isLocationPermissionGranted,
    bool? isBackgroundLocationGranted,
    RequestStatus? submitStatus,
    RequestStatus? checkLocationPermsStatus,
    int? submitCount,
    double? latitude,
    double? longitude,
    bool? isLocationDenied,
  }) {
    return EnableLocationState(
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      submitStatus: submitStatus ?? this.submitStatus,
      checkLocationPermsStatus:
          checkLocationPermsStatus ?? this.checkLocationPermsStatus,
      isAskToOpenLocationSettings:
          isAskToOpenLocationSettings ?? this.isAskToOpenLocationSettings,
      isLocationPermissionGranted:
          isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      isBackgroundLocationGranted:
          isBackgroundLocationGranted ?? this.isBackgroundLocationGranted,
      submitCount: submitCount ?? this.submitCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocationDenied: isLocationDenied ?? this.isLocationDenied,
    );
  }
}

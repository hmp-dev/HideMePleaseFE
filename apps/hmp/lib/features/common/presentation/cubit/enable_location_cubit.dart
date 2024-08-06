// ignore_for_file: unused_field

import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:mobile/app/core/cubit/cubit.dart';

part 'enable_location_state.dart';

/// Represents the result of a location request.
///
/// It can contain either a [Position] object representing the obtained
/// location or a [String] representing the error that occurred during the
/// request.
class LocationResult {
  // The obtained location.
  final Position? position;

  // The error message describing the reason for the failure.
  final String? error;

  /// Creates a [LocationResult] object.
  ///
  /// The [position] parameter is the obtained location, and the [error]
  /// parameter is the error message describing the reason for the failure.
  LocationResult({this.position, this.error});
}

@lazySingleton
class EnableLocationCubit extends BaseCubit<EnableLocationState> {
  final ProfileRepository _profileRepository;

  EnableLocationCubit(this._profileRepository)
      : super(EnableLocationState.initial());

  // write a function to check if location is enabled and emit state for value isLocationEnabled
  Future<void> checkLocationEnabled() async {
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    emit(state.copyWith(isLocationEnabled: serviceEnabled));
  }

  /// Checks the location permission and emits the state accordingly.
  ///
  /// It first emits a loading state, then checks if location services are enabled.
  /// If location services are not enabled, it emits a failure state and returns.
  ///
  /// Next, it checks for location permissions. If permissions are denied, it
  /// requests permissions and handles the result accordingly. If permissions
  /// are denied forever, it emits a failure state and returns.
  ///
  /// If permissions are granted, it emits a success state with the appropriate
  /// values for [isLocationEnabled] and [isLocationPermissionGranted].
  Future<void> checkLocationPermission() async {
    // Initialize variables
    bool serviceEnabled;
    LocationPermission permission;

    // Emit the loading state
    emit(state.copyWith(checkLocationPermsStatus: RequestStatus.loading));

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // If location services are not enabled, emit a failure state and return
    if (!serviceEnabled) {
      emit(state.copyWith(
        isLocationEnabled: false,
        isLocationPermissionGranted: false,
        checkLocationPermsStatus: RequestStatus.failure,
      ));
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();

    // If permissions are denied, request permissions and handle the result
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(
          isLocationEnabled: true,
          isLocationPermissionGranted: false,
          checkLocationPermsStatus: RequestStatus.failure,
        ));
        return;
      }
    }

    // If permissions are denied forever, emit a failure state and return
    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        isLocationEnabled: true,
        isLocationPermissionGranted: false,
        checkLocationPermsStatus: RequestStatus.failure,
      ));
      return;
    }

    // Permissions are granted, emit a success state with the appropriate values
    emit(state.copyWith(
      isLocationEnabled: true,
      isLocationPermissionGranted: true,
      checkLocationPermsStatus: RequestStatus.success,
    ));
  }

  /// Determines the device's position by checking if location services are enabled and requesting location permissions.
  ///
  /// If location services are not enabled, it returns a [LocationResult] with an error message.
  /// If location permissions are denied, it requests permissions and handles the result accordingly.
  /// If location permissions are denied forever, it handles the situation appropriately.
  /// If location permissions are granted, it returns the current position of the device.
  /// If any other unexpected error occurs, it returns a [LocationResult] with an error message.
  Future<LocationResult> _determinePosition() async {
    // Initialize variables
    bool serviceEnabled;
    LocationPermission permission;

    // Emit the state with isAskToOpenLocationSettings set to true
    emit(state.copyWith(isAskToOpenLocationSettings: true));

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are not enabled, return a LocationResult with an error message
      return LocationResult(error: 'Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();

    // If permissions are denied, request permissions and handle the result
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If permissions are denied, return a LocationResult with an error message
        return LocationResult(error: 'Location permissions are denied');
      }
    }

    // If permissions are denied forever, handle the situation appropriately
    if (permission == LocationPermission.deniedForever) {
      // If isAskToOpenLocationSettings is true, emit the state with isAskToOpenLocationSettings set to false
      if (state.isAskToOpenLocationSettings == true) {
        emit(state.copyWith(isAskToOpenLocationSettings: false));
        // Open the app settings
        await openAppSettings();
      } else {
        // If isAskToOpenLocationSettings is false, emit the state with isAskToOpenLocationSettings set to true
        emit(state.copyWith(isAskToOpenLocationSettings: true));

        // Return a LocationResult with an error message
        return LocationResult(
          error:
              'Location permissions are permanently denied, we cannot request permissions.',
        );
      }
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition();
      // Return the position as a LocationResult
      return LocationResult(position: position);
    } catch (error) {
      // If any other unexpected error occurs, return a LocationResult with an error message
      return LocationResult(error: 'Error obtaining location: $error');
    }
  }

//==================

  /// This method is responsible for asking the device location and
  /// emitting the state accordingly.
  ///
  /// It first emits a loading state, then calls the [_determinePosition]
  /// method to get the current position. If there is an error, it emits a
  /// failure state with the error message. If the position is obtained
  /// successfully, it emits a success state with the latitude, longitude,
  /// and sets [isLocationDenied] to false.
  Future<void> onAskDeviceLocation() async {
    // Emit the loading state
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    // Get the current position
    final locationResult = await _determinePosition();

    // Check if there is an error
    if (locationResult.error != null) {
      // Handle the error
      Log.debug(locationResult.error!);

      // Emit the failure state with the error message
      emit(state.copyWith(
          submitStatus: RequestStatus.failure, isLocationDenied: true));
    } else {
      // Get the position
      Position position = locationResult.position!;

      // Log the latitude and longitude
      Log.debug(
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}');

      await _profileRepository.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Emit the success state with the latitude, longitude, and set
      // [isLocationDenied] to false
      emit(state.copyWith(
        isLocationDenied: false,
        submitStatus: RequestStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
      ));
    }
  }

  void onAskDeviceLocationWithOpenSettings() async {
    var result = await openAppSettings();

    if (result) {
      "I am inside result".log();

      onAskDeviceLocation();
    }
  }
}

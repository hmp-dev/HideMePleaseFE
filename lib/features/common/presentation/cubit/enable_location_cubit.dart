// ignore_for_file: unused_field

import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:mobile/app/core/cubit/cubit.dart';

part 'enable_location_state.dart';

class LocationResult {
  final Position? position;
  final String? error;

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

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return or handle accordingly
      emit(state.copyWith(
          isLocationEnabled: false, isLocationPermissionGranted: false));
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, request permissions
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are still denied, handle accordingly
        emit(state.copyWith(
            isLocationEnabled: true, isLocationPermissionGranted: false));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly
      emit(state.copyWith(
          isLocationEnabled: true, isLocationPermissionGranted: false));
      return;
    }

    // Permissions are granted, handle accordingly
    emit(state.copyWith(
        isLocationEnabled: true, isLocationPermissionGranted: true));
  }

  Future<LocationResult> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      emit(state.copyWith(isAskToOpenLocationSettings: true));
      return LocationResult(error: 'Location services are disabled.');
    } else {
      emit(state.copyWith(isAskToOpenLocationSettings: false));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again.
        return LocationResult(error: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (state.isAskToOpenLocationSettings == true) {
        emit(state.copyWith(isAskToOpenLocationSettings: false));
        openAppSettings();
      } else {
        // at First just make true to show open setting message
        emit(state.copyWith(isAskToOpenLocationSettings: true));

        return LocationResult(
          error:
              'Location permissions are permanently denied, we cannot request permissions.',
        );
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition();
      return LocationResult(position: position);
    } catch (error) {
      // Handle any other unexpected errors
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
  void onAskDeviceLocation() async {
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

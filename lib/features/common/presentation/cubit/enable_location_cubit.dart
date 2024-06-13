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

  void onAskDeviceLocation() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final locationResult = await _determinePosition();

    if (locationResult.error != null) {
      // Handle the error
      Log.debug(locationResult.error!);
      emit(state.copyWith(
          submitStatus: RequestStatus.failure, isLocationDenied: true));
    } else {
      // Location obtained successfully, do something with the position
      Position position = locationResult.position!;
      Log.debug(
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}');

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

// ignore_for_file: unused_field

import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';

export 'package:mobile/app/core/cubit/cubit.dart';

part 'submit_location_state.dart';

@lazySingleton
class SubmitLocationCubit extends BaseCubit<SubmitLocationState> {
  final ProfileRepository _profileRepository;

  // Constructor for SubmitLocationCubit
  //
  // Takes a ProfileRepository as a parameter and initializes the state to initial
  SubmitLocationCubit(this._profileRepository)
      : super(SubmitLocationState.initial());

  // Submits the user's device location to the server
  //
  // Calls Geolocator.getCurrentPosition to get the user's current position
  // and then calls ProfileRepository.updateUserLocation to submit the location
  // to the server. If successful, updates the state with the new latitude and
  // longitude. If there is an error, updates the state with the error message.
  Future<void> onSubmitUserDeviceLocation() async {
    try {
      // Get the current position of the user
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the user's location on the server
      final response = await _profileRepository.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Handle the response from the server
      response.fold(
        // If there was an error, update the state with the error message
        (error) {
          emit(
            state.copyWith(
              errorMessage: error.message,
              isLocationSubmitted: false,
            ),
          );
        },
        // If successful, update the state with the new latitude and longitude
        (success) {
          emit(
            state.copyWith(
              errorMessage: '',
              latitude: position.latitude,
              longitude: position.longitude,
              isLocationSubmitted: true,
            ),
          );
        },
      );
    } catch (e) {
      // If there was an error getting the current position, update the state with the error message
      emit(
        state.copyWith(
          errorMessage: '$e',
          isLocationSubmitted: false,
        ),
      );
    }
  }
}

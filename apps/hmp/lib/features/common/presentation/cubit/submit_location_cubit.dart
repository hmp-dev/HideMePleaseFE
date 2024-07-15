// ignore_for_file: unused_field

import 'package:geolocator/geolocator.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';

export 'package:mobile/app/core/cubit/cubit.dart';

part 'submit_location_state.dart';

@lazySingleton
class SubmitLocationCubit extends BaseCubit<SubmitLocationState> {
  final ProfileRepository _profileRepository;

  SubmitLocationCubit(this._profileRepository)
      : super(SubmitLocationState.initial());

  onSubmitUserDeviceLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await _profileRepository.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      response.fold(
        (error) {
          emit(
            state.copyWith(
              errorMessage: error.message,
              isLocationSubmitted: false,
            ),
          );
        },
        (success) {
          emit(
            state.copyWith(
              errorMessage: '',
              latitude: state.latitude,
              longitude: state.longitude,
              isLocationSubmitted: true,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: '$e',
          isLocationSubmitted: false,
        ),
      );
    }
  }
}

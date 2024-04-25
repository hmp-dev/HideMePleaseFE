import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/common/domain/entities/user_entity.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'profile_state.dart';

@lazySingleton
class ProfileCubit extends BaseCubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(
    this._profileRepository,
  ) : super(ProfileState.initial());

  Future<void> onGetUserProfile() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    final response = await _profileRepository.getProfileData();
    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
          isProfileIncomplete: false,
        ));
      },
      (user) {
        // if users
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            userProfile: user.toEntity(),
            isProfileIncomplete: false,
          ),
        );
      },
    );
  }
}

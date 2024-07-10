import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'profile_state.dart';

@lazySingleton
class ProfileCubit extends BaseCubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final ChatRepository _chatRepository;

  ProfileCubit(
    this._profileRepository,
    this._chatRepository,
  ) : super(ProfileState.initial());

  Future<void> init() async {
    await Future.wait([
      onGetBaseUser(),
      onGetUserProfile(),
    ]);

    // init chat
    await _chatRepository.init(
      userId: state.userProfileEntity.id,
      appId: state.userProfileEntity.chatAppId,
      accessToken: state.userProfileEntity.chatAccessToken,
    );
  }

  Future<void> onGetBaseUser() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));
    final response = await _profileRepository.getBaseUserData();
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
            baseUserData: user.toEntity(),
            isProfileIncomplete: false,
          ),
        );
      },
    );
  }

  Future<void> onGetUserProfile() async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response = await _profileRepository.getUserProfileData();
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
            userProfileEntity: user.toEntity(),
            isProfileIncomplete: false,
          ),
        );
      },
    );
  }

  Future<void> onUpdateUserProfile(
    UpdateProfileRequestDto updateProfileRequestDto,
  ) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    EasyLoading.show();

    final response = await _profileRepository.updateProfileData(
        updateProfileRequestDto: updateProfileRequestDto);

    EasyLoading.dismiss();

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
            userProfileEntity: user.toEntity(),
            isProfileIncomplete: false,
          ),
        );

        onGetUserProfile();
      },
    );
  }
}

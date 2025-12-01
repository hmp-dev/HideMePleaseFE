import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/my/domain/entities/base_user_entity.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/domain/entities/point_transaction_entity.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';

part 'profile_state.dart';

@lazySingleton
class ProfileCubit extends BaseCubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(
    this._profileRepository,
  ) : super(ProfileState.initial());

  Future<void> init() async {
    await Future.wait([
      onGetBaseUser(),
      onGetUserProfile(),
    ]);
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
      (user) async {
        var userEntity = user.toEntity();

        // Don't load from local storage - trust server response for new users
        // This prevents old user data from affecting new email signups

        // Save profile parts status to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final hasProfileParts = userEntity.profilePartsString != null &&
                               userEntity.profilePartsString!.isNotEmpty;
        await prefs.setBool(StorageValues.hasProfileParts, hasProfileParts);
        print('💾 Saved profile parts status to SharedPreferences: $hasProfileParts');
        
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            userProfileEntity: userEntity,
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

    // Save profilePartsString to local storage if provided
    if (updateProfileRequestDto.profilePartsString != null &&
        updateProfileRequestDto.profilePartsString!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePartsString', updateProfileRequestDto.profilePartsString!);
      print('💾 Saved profilePartsString to local storage');
    }

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

  /// Update user profile silently without showing EasyLoading
  /// Useful for background updates like app version and OS info
  Future<void> updateProfileSilently(
    UpdateProfileRequestDto updateProfileRequestDto,
  ) async {
    emit(state.copyWith(submitStatus: RequestStatus.loading));

    // Save profilePartsString to local storage if provided
    if (updateProfileRequestDto.profilePartsString != null &&
        updateProfileRequestDto.profilePartsString!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePartsString', updateProfileRequestDto.profilePartsString!);
      print('💾 Saved profilePartsString to local storage');
    }

    // No EasyLoading for silent update
    final response = await _profileRepository.updateProfileData(
        updateProfileRequestDto: updateProfileRequestDto);

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
          isProfileIncomplete: false,
        ));
      },
      (user) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            userProfileEntity: user.toEntity(),
            isProfileIncomplete: false,
          ),
        );

        // Don't call onGetUserProfile() again for silent updates
        // to avoid overwriting the update
      },
    );
  }
  
  // Method to display profile with just parts string (for other users)
  Future<void> loadProfileFromParts(String profilePartsString) async {
    if (profilePartsString.isNotEmpty) {
      final currentEntity = state.userProfileEntity ?? const UserProfileEntity.empty();
      emit(
        state.copyWith(
          userProfileEntity: currentEntity.copyWith(
            profilePartsString: profilePartsString,
          ),
        ),
      );
    }
  }
  
  // Check if user has profile parts
  Future<bool> hasProfileParts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageValues.hasProfileParts) ?? false;
  }

  /// 포인트 거래 내역 조회 (SAV 히스토리)
  Future<void> getPointsHistory() async {
    emit(state.copyWith(pointsHistoryStatus: RequestStatus.loading));

    final response = await _profileRepository.getPointsHistory(
      page: 1,
      limit: 100, // 전체 내역을 한 번에 조회
    );

    response.fold(
      (err) {
        emit(state.copyWith(
          pointsHistoryStatus: RequestStatus.failure,
          pointsHistory: [],
        ));
      },
      (historyResponse) {
        final transactions = historyResponse.transactions
            .map((dto) => dto.toEntity())
            .toList();

        emit(state.copyWith(
          pointsHistoryStatus: RequestStatus.success,
          pointsHistory: transactions,
        ));
      },
    );
  }
}

// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/storage/secure_storage.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/wepin/cubit/wepin_cubit.dart';

part 'app_state.dart';

@lazySingleton
class AppCubit extends BaseCubit<AppState> {
  final AuthRepository _authRepository;

  AppCubit(this._authRepository) : super(AppState.initial());

  final SecureStorage _secureStorage = getIt<SecureStorage>();

  Future<void> onStart() async {
    await _updateAuthStatus();
  }

  Future<void> _updateAuthStatus() async {
    final authTokenRes = await _authRepository.getAuthToken();

    authTokenRes.fold(
      (error) => emit(
        state.copyWith(isLoggedIn: false),
      ),
      (authToken) async {
        emit(state.copyWith(isLoggedIn: true));
      },
    );
  }

  Future<void> onLogOut() async {
    if (!state.isLoggedIn) return;
    ("inside onLogOut").log();
    EasyLoading.show();

    final result = await _authRepository.requestLogOut();

    result.fold(
      (l) => ("inside onLogOut Error").log(),
      (r) async {
        _secureStorage.delete(StorageValues.appleIdToken);
        _secureStorage.delete(StorageValues.googleAccessToken);
        _secureStorage.delete(StorageValues.socialTokenIsAppleOrGoogle);

        // logout from wepin
        await getIt<WepinCubit>().onLogoutWepinSdk();
        // emit state for login status as false
        emit(state.copyWith(isLoggedIn: false));
      },
    );

    EasyLoading.dismiss();

    await getIt.reset();

    // DI
    await configureDependencies();

    onStart();
  }

  Future<void> onRefresh() async {
    if (!state.isLoggedIn) return;

    await getIt.reset();

    // DI
    await configureDependencies();

    onStart();
  }

  void markInitialized() {
    emit(state.copyWith(initialized: true));
  }

  void markUnInitialized() {
    emit(state.copyWith(initialized: false));
  }
}

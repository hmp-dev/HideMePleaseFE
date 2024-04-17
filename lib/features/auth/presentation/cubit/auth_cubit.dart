// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends BaseCubit<AuthState> {
  AuthCubit(this._authRepository) : super(AuthState.initial());

  final AuthRepository _authRepository;

  Future<void> onGoogleLogin() async {
    final result = await _authRepository.requestGoogleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) {
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<void> onAppleLogin() async {
    final result = await _authRepository.requestAppleLogin();
    result.fold(
      (l) => emit(
        state.copyWith(submitStatus: RequestStatus.failure, message: l.message),
      ),
      (idToken) {
        onBackendApiLogin(firebaseIdToken: idToken);
      },
    );
  }

  Future<void> onWorldIdLogin() async {}
  Future<void> onBackendApiLogin({
    required String firebaseIdToken,
  }) async {
    //
    EasyLoading.show();

    emit(state.copyWith(submitStatus: RequestStatus.loading));

    final response =
        await _authRepository.requestApiLogin(firebaseToken: firebaseIdToken);

    EasyLoading.dismiss();

    //
    response.fold(
      (err) => emit(state.copyWith(
          submitStatus: RequestStatus.failure, isLogInSuccessful: false)),
      (success) => emit(
        state.copyWith(
          submitStatus: RequestStatus.success,
          isLogInSuccessful: true,
        ),
      ),
    );
  }

  Future<void> onLogOut() async {
    Log.info("inside onLogOut");
    EasyLoading.show();

    final response = await _authRepository.requestLogOut();

    EasyLoading.dismiss();

    response.fold(
      (err) => emit(state.copyWith(submitStatus: RequestStatus.failure)),
      (success) => emit(
        state.copyWith(
          submitStatus: RequestStatus.success,
          isLogInSuccessful: false,
        ),
      ),
    );
  }
}

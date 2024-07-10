// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

part 'app_state.dart';

@lazySingleton
class AppCubit extends BaseCubit<AppState> {
  final AuthRepository _authRepository;

  AppCubit(this._authRepository) : super(AppState.initial());

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
    ("inside onLogOut").log();
    EasyLoading.show();

    final result = await _authRepository.requestLogOut();

    result.fold(
      (l) => ("inside onLogOut Error").log(),
      (r) => ("inside onLogOut Success").log(),
    );

    EasyLoading.dismiss();

    await getIt.reset();

    // DI
    await configureDependencies();

    onStart();
  }
}

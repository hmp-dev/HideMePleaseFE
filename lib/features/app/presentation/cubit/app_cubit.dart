// ignore_for_file: unused_field

import 'dart:async';

import 'package:mobile/app/core/cubit/cubit.dart';

part 'app_state.dart';

@lazySingleton
class AppCubit extends BaseCubit<AppState> {
  Timer? _locationPolling;

  AppCubit() : super(AppState.initial());

  Future<void> onStart() async {
    await _updateAuthStatus();
  }

  Future<void> _updateAuthStatus() async {
    emit(state.copyWith(isLoggedIn: false));
  }

  Future<void> onLogOut() async {}

  @override
  Future<void> close() {
    _locationPolling?.cancel();
    return super.close();
  }
}

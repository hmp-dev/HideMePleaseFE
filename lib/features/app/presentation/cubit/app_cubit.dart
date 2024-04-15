// ignore_for_file: unused_field

import 'dart:async';

import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/logger/logger.dart';

part 'app_state.dart';

@lazySingleton
class AppCubit extends BaseCubit<AppState> {
  AppCubit() : super(AppState.initial());

  Future<void> onStart() async {
    emit(state.copyWith(status: RequestStatus.loading));
    Log.info("OnStart is called");
    emit(state.copyWith(status: RequestStatus.success, isLoggedIn: false));
  }

  Future<void> _updateAuthStatus() async {}

  Future<void> onLogOut() async {}
}

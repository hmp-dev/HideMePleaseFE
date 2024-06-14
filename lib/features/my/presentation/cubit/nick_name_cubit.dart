import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/my/domain/repositories/profile_repository.dart';

part 'nick_name_state.dart';

@lazySingleton
class NickNameCubit extends BaseCubit<NickNameState> {
  final ProfileRepository _profileRepository;

  NickNameCubit(
    this._profileRepository,
  ) : super(NickNameState.initial());

  Timer? _nickNameDebounceTimer;

  onCheckNickName({required String nickName}) async {
    emit(NickNameState.initial());

    if (nickName.isEmpty || nickName.length > 8) return;

    _nickNameDebounceTimer?.cancel();
    _nickNameDebounceTimer =
        Timer(const Duration(milliseconds: 1000), () async {
      EasyLoading.show();

      final usernameAvailableRes =
          await _profileRepository.getRequestCheckNickNameExists(nickName);

      EasyLoading.dismiss();

      usernameAvailableRes.fold(
        (error) => emit(state.copyWith(
          isNickNameAvailable: false,
          nickNameError: true,
          nickName: nickName,
        )),
        (isExist) => emit(state.copyWith(
          // isExists is false mean Nick Name is Available
          nickName: nickName,
          isNickNameAvailable: isExist,
          nickNameError: isExist,
        )),
      );
    });
  }
}

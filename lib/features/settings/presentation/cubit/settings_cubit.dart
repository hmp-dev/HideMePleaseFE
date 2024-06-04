import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/settings/domain/entities/cms_link_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends BaseCubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(
    this._settingsRepository,
  ) : super(SettingsState.initial());

  Future<void> onGetCMSlink() async {
    emit(SettingsState.initial());

    EasyLoading.show();

    final response = await _settingsRepository.getCmsLink();

    EasyLoading.dismiss();

    response.fold(
      (err) {
        emit(state.copyWith(
          submitStatus: RequestStatus.failure,
          errorMessage: LocaleKeys.somethingError.tr(),
        ));
      },
      (result) {
        emit(
          state.copyWith(
            submitStatus: RequestStatus.success,
            errorMessage: '',
            cmsLinkEntity: result.toEntity(),
          ),
        );
      },
    );
  }
}

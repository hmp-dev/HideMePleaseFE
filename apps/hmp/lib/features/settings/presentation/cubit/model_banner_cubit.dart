import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/features/settings/domain/entities/model_banner_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';

part 'model_banner_state.dart';

@lazySingleton
class ModelBannerCubit extends BaseCubit<ModelBannerState> {
  final SettingsRepository _settingsRepository;

  ModelBannerCubit(
    this._settingsRepository,
  ) : super(ModelBannerState.initial());

  Future<void> onGetModelBannerInfo() async {
    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      errorMessage: '',
    ));

    final response = await _settingsRepository.getModelBannerInfo();

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
            modelBannerEntity: result.toEntity(),
          ),
        );
      },
    );
  }
}

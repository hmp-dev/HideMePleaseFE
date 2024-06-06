import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/settings/domain/entities/announcement_entity.dart';
import 'package:mobile/features/settings/domain/entities/settings_banner_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends BaseCubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(
    this._settingsRepository,
  ) : super(SettingsState.initial());

  Future<void> onGetSettingBannerInfo() async {
    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      errorMessage: '',
    ));

    EasyLoading.show();

    final response = await _settingsRepository.getSettingBannerInfo();

    // call get App Version Info Cubit function
    onGetAppVersion();

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
            settingsBannerEntity: result.toEntity(),
          ),
        );
      },
    );
  }

  onGetAnnouncements() async {
    EasyLoading.show();

    final response = await _settingsRepository.getAnnouncements();

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
            announcements: result.map((e) => e.toEntity()).toList(),
          ),
        );
      },
    );
  }

  onGetAppVersion() async {
    Upgrader upgrader = Upgrader();

    await upgrader.initialize();

    final upgradeData = await upgrader.updateVersionInfo();

    ("upgradeData?.appStoreVersion ${upgradeData?.appStoreVersion}").log();
    ("upgradeData?.installedVersion ${upgradeData?.installedVersion}").log();
    ("upgradeData?.appStoreVersion $upgradeData").log();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    ("App Name: $appName").log();
    ("Package Name: $packageName").log();
    ("Version: $version").log();
    ("Build Number: $buildNumber").log();

    emit(state.copyWith(
      storeVersion: upgradeData?.appStoreVersion?.toString(),
      installedVersion: upgradeData?.installedVersion?.toString(),
      buildNumber: buildNumber,
    ));
  }

  onSendUserToAppStore() async {
    EasyLoading.show();

    try {
      Upgrader upgrader = Upgrader();
      await upgrader.initialize();
      upgrader.sendUserToAppStore();
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.show();
    }
  }

  onRequestDeleteUser() async {
    emit(state.copyWith(
      submitStatus: RequestStatus.loading,
      errorMessage: '',
    ));
    EasyLoading.show();

    final response = await _settingsRepository.requestDeleteUser();

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
          ),
        );
      },
    );
  }
}

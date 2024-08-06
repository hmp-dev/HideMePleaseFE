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

  /// Retrieves the settings banner information from the server using the
  /// SettingsRepository and emits the states accordingly.
  ///
  /// The cubit starts by emitting the loading state. If the repository
  /// returns a failure, the cubit emits the failure state with the
  /// 'somethingError' translated message. If the repository returns a success,
  /// the cubit emits the success state with the settings banner information
  /// mapped to a SettingsBannerEntity object.
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

  /// Retrieves the announcements from the server using the
  /// SettingsRepository and emits the states accordingly.
  ///
  /// The cubit starts by showing the loading indicator. If the repository
  /// returns a failure, the cubit emits the failure state with the
  /// 'somethingError' translated message. If the repository returns a success,
  /// the cubit emits the success state with the announcements mapped to
  /// AnnouncementEntity objects.
  Future<void> onGetAnnouncements() async {
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

  /// Retrieves the app version information using the PackageInfo class and
  /// emits the states accordingly.
  ///
  /// The cubit starts by initializing the Upgrader class and retrieving the
  /// upgrade data. It then logs the app store version, installed version, and
  /// build number. It also retrieves the app name, package name, version, and
  /// build number using the PackageInfo class. Finally, it emits the states
  /// with the retrieved information.
  Future<void> onGetAppVersion() async {
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

  /// Sends the user to the app store using the Upgrader class.
  ///
  /// The cubit starts by showing the loading indicator. It then initializes
  /// the Upgrader class and sends the user to the app store. If an error occurs,
  /// the loading indicator is shown again.
  Future<void> onSendUserToAppStore() async {
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

  /// Sends a request to delete the user's account.
  ///
  /// The cubit starts by emitting the loading state. It then shows the loading
  /// indicator and sends a request to delete the user's account using the
  /// SettingsRepository. If the request fails, the cubit emits the failure state
  /// with the 'somethingError' translated message. If the request succeeds, the
  /// cubit emits the success state with the withdrawal successful flag set to
  /// true.
  Future<void> onRequestDeleteUser() async {
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
            isWithdrawalSuccessful: true,
            submitStatus: RequestStatus.success,
            errorMessage: '',
          ),
        );
      },
    );
  }
}

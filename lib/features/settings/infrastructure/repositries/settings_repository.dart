import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/features/settings/infrastructure/data_sources/settings_remote_data_source.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/notification_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/settings_banner_dto.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImp implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  const SettingsRepositoryImp(this._remoteDataSource);

  @override
  Future<Either<HMPError, SettingsBannerDto>> getSettingBannerInfo() async {
    try {
      final response = await _remoteDataSource.getSettingsBannerInfo();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<AnnouncementDto>>> getAnnouncements() async {
    try {
      final response = await _remoteDataSource.requestGetAnnouncements();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, bool>> requestDeleteUser() async {
    try {
      final response = await _remoteDataSource.requestDeleteUser();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }

  @override
  Future<Either<HMPError, List<NotificationDto>>> getNotifications() async {
    try {
      final response = await _remoteDataSource.getUserNotifications();
      return right(response);
    } on DioException catch (e, t) {
      return left(HMPError.fromNetwork(
        message: e.message,
        error: e,
        trace: t,
      ));
    } catch (e, t) {
      return left(HMPError.fromUnknown(
        error: e,
        trace: t,
      ));
    }
  }
}

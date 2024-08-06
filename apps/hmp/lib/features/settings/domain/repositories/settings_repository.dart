import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/notification_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/settings_banner_dto.dart';

/// `SettingsRepository` defines the methods to fetch data from the server.
/// It specifies the contract for fetching settings banner info, announcements,
/// user notifications and requesting user deletion.
abstract class SettingsRepository {
  /// Fetches the settings banner info from the server.
  ///
  /// Returns a `Either<HMPError, SettingsBannerDto>` which is either a `SettingsBannerDto`
  /// or an `HMPError` in case of failure.
  Future<Either<HMPError, SettingsBannerDto>> getSettingBannerInfo();

  /// Fetches the announcements from the server.
  ///
  /// Returns a `Either<HMPError, List<AnnouncementDto>>` which is either a `List<AnnouncementDto>`
  /// or an `HMPError` in case of failure.
  Future<Either<HMPError, List<AnnouncementDto>>> getAnnouncements();

  /// Sends a request to the server to delete the user.
  ///
  /// Returns a `Either<HMPError, bool>` which is either `true` or an `HMPError` in case of failure.
  Future<Either<HMPError, bool>> requestDeleteUser();

  /// Fetches the user notifications from the server.
  ///
  /// Returns a `Either<HMPError, List<NotificationDto>>` which is either a `List<NotificationDto>`
  /// or an `HMPError` in case of failure.
  Future<Either<HMPError, List<NotificationDto>>> getNotifications();
}

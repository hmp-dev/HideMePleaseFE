import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/settings_banner_dto.dart';

abstract class SettingsRepository {
  Future<Either<HMPError, SettingsBannerDto>> getSettingBannerInfo();

  Future<Either<HMPError, List<AnnouncementDto>>> getAnnouncements();

  Future<Either<HMPError, bool>> requestDeleteUser();
}

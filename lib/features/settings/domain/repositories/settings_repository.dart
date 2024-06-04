import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/settings/infrastructure/dtos/cms_link_dto.dart';

abstract class SettingsRepository {
  Future<Either<HMPError, CmsLinkDto>> getCmsLink();
}

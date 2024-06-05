import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/cms_link_dto.dart';

@lazySingleton
class SettingsRemoteDataSource {
  final Network _network;

  SettingsRemoteDataSource(this._network);

  Future<CmsLinkDto> getPartnerProgramLink() async {
    final response = await _network.get("cms/partner-program", {});
    return CmsLinkDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AnnouncementDto>> requestGetAnnouncements() async {
    final response = await _network.get("cms/announcements", {});
    return response.data
        .map<AnnouncementDto>(
            (e) => AnnouncementDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

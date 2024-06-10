import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/settings_banner_dto.dart';

@lazySingleton
class SettingsRemoteDataSource {
  final Network _network;

  SettingsRemoteDataSource(this._network);

  Future<SettingsBannerDto> getSettingsBannerInfo() async {
    final response = await _network.get("cms/settings/banner", {});
    return SettingsBannerDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AnnouncementDto>> requestGetAnnouncements() async {
    final response = await _network.get("cms/announcements", {});
    return response.data
        .map<AnnouncementDto>(
            (e) => AnnouncementDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> requestDeleteUser() async {
    final response = await _network.request("/user", 'DELETE', {});

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}

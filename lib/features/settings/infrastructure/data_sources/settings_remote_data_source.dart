import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/settings/infrastructure/dtos/cms_link_dto.dart';

@lazySingleton
class SettingsRemoteDataSource {
  final Network _network;

  SettingsRemoteDataSource(this._network);

  Future<CmsLinkDto> getPartnerProgramLink() async {
    final response = await _network.get("cms/partner-program", {});
    return CmsLinkDto.fromJson(response.data as Map<String, dynamic>);
  }
}

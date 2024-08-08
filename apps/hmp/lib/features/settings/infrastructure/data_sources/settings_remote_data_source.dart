import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/settings/infrastructure/dtos/announcement_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/model_banner_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/notification_dto.dart';
import 'package:mobile/features/settings/infrastructure/dtos/settings_banner_dto.dart';

@lazySingleton
class SettingsRemoteDataSource {
  final Network _network;

  /// Creates a new instance of [SettingsRemoteDataSource].
  ///
  /// The [_network] parameter represents the network layer of the application.
  /// It is used to make HTTP requests.
  SettingsRemoteDataSource(this._network);

  /// Retrieves the settings banner information from the server.
  ///
  /// It sends a GET request to the "cms/settings/banner" endpoint and returns
  /// the parsed response as a [SettingsBannerDto] object.
  Future<SettingsBannerDto> getSettingsBannerInfo() async {
    // Send a GET request to the "cms/settings/banner" endpoint.
    final response = await _network.get("cms/settings/banner", {});

    // Parse the response data into a [SettingsBannerDto] object.
    return SettingsBannerDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ModelBannerDto> getModelBannerInfo() async {
    // Send a GET request to the "cms/modal/banner" endpoint.
    final response = await _network.get("cms/modal/banner", {});

    // Parse the response data into a [ModelBannerDto] object.
    return ModelBannerDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Retrieves the announcements from the server.
  ///
  /// It sends a GET request to the "cms/announcements" endpoint and returns
  /// the parsed response as a list of [AnnouncementDto] objects.
  Future<List<AnnouncementDto>> requestGetAnnouncements() async {
    // Send a GET request to the "cms/announcements" endpoint.
    final response = await _network.get("cms/announcements", {});

    // Parse the response data into a list of [AnnouncementDto] objects.
    return response.data
        .map<AnnouncementDto>(
            (e) => AnnouncementDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends a DELETE request to the "/user" endpoint to delete the user.
  ///
  /// It returns [true] if the request is successful (status code 200),
  /// otherwise it returns [false].
  Future<bool> requestDeleteUser() async {
    // Send a DELETE request to the "/user" endpoint.
    final response = await _network.request("/user", 'DELETE', {});

    // Check if the request was successful (status code 200).
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  /// Retrieves the user notifications from the server.
  ///
  /// It sends a GET request to the "/notification" endpoint and returns
  /// the parsed response as a list of [NotificationDto] objects.
  Future<List<NotificationDto>> getUserNotifications() async {
    // Send a GET request to the "/notification" endpoint.
    final response = await _network.get('/notification', {});

    // Parse the response data into a list of [NotificationDto] objects.
    return (response.data as List)
        .map((e) => NotificationDto.fromJson(e))
        .toList();
  }
}

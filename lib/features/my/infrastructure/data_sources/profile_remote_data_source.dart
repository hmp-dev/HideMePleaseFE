import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/base_user_dto.dart';
import 'package:mobile/features/my/infrastructure/dtos/user_profile_dto.dart';

@lazySingleton
class ProfileRemoteDataSource {
  final Network _network;

  ProfileRemoteDataSource(this._network);

  Future<BaseUserDto> getBaseUserData() async {
    final response = await _network.get("user", {});
    return BaseUserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileDto> getProfileData() async {
    final response = await _network.get("user/profile", {});
    return UserProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfileDto> putProfileData({
    required UpdateProfileRequestDto updateProfileRequestDto,
  }) async {
    final response = await _network.request(
        "user/profile", 'PATCH', updateProfileRequestDto.toJson());
    return UserProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> checkNickNameExist(String nickName) async {
    final response =
        await _network.get("user/nickName/exists?nickName=$nickName", {});

    "the response data is: ${response.data}".log();
    "the response data type is: ${response.data.runtimeType}".log();

    if (response.statusCode == 200) {
      if (response.data == "false") {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}

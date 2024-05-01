import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/update_profile_request_dto.dart';
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
}

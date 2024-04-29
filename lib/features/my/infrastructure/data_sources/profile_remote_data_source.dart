import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/common/infrastructure/dtos/user_dto.dart';

@lazySingleton
class ProfileRemoteDataSource {
  final Network _network;

  ProfileRemoteDataSource(this._network);

  Future<UserDto> getProfileData() async {
    final response = await _network.get("user", {});
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserDto> putProfileData({
    required UpdateProfileRequestDto updateProfileRequestDto,
  }) async {
    final response = await _network.request(
        "user/profile", 'PATCH', updateProfileRequestDto.toJson());
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }
}

import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/network/network.dart';
import 'package:mobile/features/common/infrastructure/dtos/user_dto.dart';

@lazySingleton
class ProfileRemoteDataSource {
  final Network _network;

  ProfileRemoteDataSource(this._network);

  Future<UserDto> getProfileData() async {
    final response = await _network.get("user", {});
    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }
}

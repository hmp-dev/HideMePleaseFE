import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/features/space/domain/entities/check_in_users_response_entity.dart';
import 'package:mobile/features/space/domain/repositories/space_repository.dart';

@lazySingleton
class GetCheckInUsersUseCase {
  final SpaceRepository _repository;

  GetCheckInUsersUseCase(this._repository);

  Future<Either<HMPError, CheckInUsersResponseEntity>> call(
      GetCheckInUsersParams params) {
    return _repository.getCheckInUsers(spaceId: params.spaceId);
  }
}

class GetCheckInUsersParams {
  final String spaceId;

  GetCheckInUsersParams({required this.spaceId});
}

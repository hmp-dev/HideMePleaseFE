import 'package:dartz/dartz.dart';
import 'package:mobile/app/core/error/error.dart';

abstract class ChatRepository {
  Future<Either<HMPError, Unit>> init({
    required String userId,
    required String appId,
    String? accessToken,
  });
}

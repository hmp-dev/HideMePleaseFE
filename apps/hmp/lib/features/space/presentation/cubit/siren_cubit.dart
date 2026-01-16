import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/app/core/constants/storage.dart';
import 'package:mobile/app/core/error/error.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/features/space/domain/entities/siren_entity.dart';
import 'package:mobile/features/space/infrastructure/data_sources/siren_remote_data_source.dart';
import 'package:mobile/features/space/presentation/cubit/siren_state.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

@lazySingleton
class SirenCubit extends Cubit<SirenState> {
  final SirenRemoteDataSource _sirenRemoteDataSource;

  SirenCubit(this._sirenRemoteDataSource) : super(const SirenState());

  /// 사이렌 목록 조회
  Future<void> fetchSirenList({
    String sortBy = 'time',
    double? latitude,
    double? longitude,
    int page = 1,
    int limit = 20,
    String? spaceId,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));

      final response = await _sirenRemoteDataSource.getSirenList(
        sortBy: sortBy,
        latitude: latitude,
        longitude: longitude,
        page: page,
        limit: limit,
        spaceId: spaceId,
      );

      final entity = response.toEntity();
      List<SirenEntity> sirens = entity.sirens;

      // 클라이언트에서 거리 재계산 (distance가 0이고 위치 정보가 있는 경우)
      if (latitude != null && longitude != null) {
        sirens = sirens.map((siren) {
          if (siren.distance == 0.0 &&
              siren.space != null &&
              siren.space!.latitude != 0.0 &&
              siren.space!.longitude != 0.0) {

            final calculatedDistance = calculateDistanceInMeters(
              latitude,
              longitude,
              siren.space!.latitude,
              siren.space!.longitude,
            );

            print('🔄 [SirenCubit] Recalculated distance for ${siren.space!.name}: ${calculatedDistance.toStringAsFixed(0)}m');

            return SirenEntity(
              id: siren.id,
              message: siren.message,
              createdAt: siren.createdAt,
              expiresAt: siren.expiresAt,
              pointsSpent: siren.pointsSpent,
              remainingDays: siren.remainingDays,
              space: siren.space,
              author: siren.author,
              distance: calculatedDistance,
            );
          }
          return siren;
        }).toList();
      }

      // 신고된 사이렌 + 차단된 유저 필터링
      sirens = sirens.where((siren) =>
          !state.reportedSirenIds.contains(siren.id) &&
          !state.blockedUserIds.contains(siren.author?.userId)
      ).toList();

      emit(state.copyWith(
        isLoading: false,
        sirenList: sirens,
        sirenListResponse: entity,
        sortBy: sortBy,
        currentPage: page,
      ));
    } on HMPError catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// 내 사이렌 목록 조회
  Future<void> fetchMySirenList() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: ''));

      final response = await _sirenRemoteDataSource.getMySirenList();
      final entity = response.toEntity();

      emit(state.copyWith(
        isLoading: false,
        sirenList: entity.sirens,
        sirenListResponse: entity,
      ));
    } on HMPError catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// 사이렌 생성
  Future<bool> createSiren({
    required String spaceId,
    required String message,
    required int days, // hours를 전달받아도 days로 처리
  }) async {
    try {
      emit(state.copyWith(isCreating: true, errorMessage: ''));

      // Calculate expiresAt based on hours (days parameter actually contains hours)
      // hours가 전달되면 시간으로 계산
      final expiresAt = DateTime.now()
          .add(Duration(hours: days)) // 실제로는 hours
          .toUtc()
          .toIso8601String();

      final response = await _sirenRemoteDataSource.createSiren(
        spaceId: spaceId,
        message: message,
        expiresAt: expiresAt,
      );

      final entity = response.toEntity();

      emit(state.copyWith(
        isCreating: false,
        createResponse: entity,
      ));

      return entity.success;
    } on HMPError catch (e) {
      // 에러 코드에 따라 적절한 번역 메시지 표시
      final errorMessage = _getErrorMessageForCode(e.error ?? e.message);

      emit(state.copyWith(
        isCreating: false,
        errorMessage: errorMessage,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: LocaleKeys.somethingError.tr(),
      ));
      return false;
    }
  }

  /// 사이렌 삭제
  Future<bool> deleteSiren({required String sirenId}) async {
    try {
      emit(state.copyWith(isDeleting: true, errorMessage: ''));

      final success = await _sirenRemoteDataSource.deleteSiren(
        sirenId: sirenId,
      );

      emit(state.copyWith(isDeleting: false));

      if (success) {
        // Remove deleted siren from the list
        final updatedList = state.sirenList
            .where((siren) => siren.id != sirenId)
            .toList();

        emit(state.copyWith(sirenList: updatedList));
      }

      return success;
    } on HMPError catch (e) {
      // 에러 코드에 따라 적절한 번역 메시지 표시
      final errorMessage = _getErrorMessageForCode(e.error ?? e.message);

      emit(state.copyWith(
        isDeleting: false,
        errorMessage: errorMessage,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: LocaleKeys.somethingError.tr(),
      ));
      return false;
    }
  }

  /// 매장별 사이렌 통계 조회
  Future<void> fetchSirenStats({required String spaceId}) async {
    try {
      final response = await _sirenRemoteDataSource.getSirenStats(
        spaceId: spaceId,
      );

      final entity = response.toEntity();

      emit(state.copyWith(stats: entity));
    } on HMPError catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// 정렬 방식 변경
  void changeSortBy(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
  }

  /// 에러 메시지 초기화
  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }

  /// 에러 코드에 따라 적절한 번역 메시지 반환
  String _getErrorMessageForCode(String errorCode) {
    // 에러 코드가 메시지에 포함되어 있는지 확인
    final code = errorCode.toUpperCase();

    if (code.contains('SIREN_DURATION_TOO_SHORT')) {
      return LocaleKeys.siren_error_duration_too_short.tr();
    } else if (code.contains('SIREN_DURATION_TOO_LONG')) {
      return LocaleKeys.siren_error_duration_too_long.tr();
    } else if (code.contains('SIREN_EXPIRES_IN_PAST')) {
      return LocaleKeys.siren_error_expires_in_past.tr();
    } else if (code.contains('SIREN_MESSAGE_INVALID_LENGTH')) {
      return LocaleKeys.siren_error_message_invalid_length.tr();
    } else if (code.contains('SIREN_MAX_ACTIVE_LIMIT_EXCEEDED')) {
      return LocaleKeys.siren_error_max_active_limit_exceeded.tr();
    } else if (code.contains('SIREN_NOT_OWNER')) {
      return LocaleKeys.siren_error_not_owner.tr();
    } else if (code.contains('POINT_INSUFFICIENT_BALANCE')) {
      return LocaleKeys.siren_error_point_insufficient_balance.tr();
    } else {
      // 알 수 없는 에러인 경우 원본 메시지 반환
      return errorCode;
    }
  }

  /// 신고된 사이렌 ID 목록 로드
  Future<void> loadReportedSirenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final reported = prefs.getStringList(StorageValues.reportedSirenIds) ?? [];
    emit(state.copyWith(reportedSirenIds: reported.toSet()));
  }

  /// 사이렌 신고 처리
  Future<void> reportSiren(String sirenId) async {
    final prefs = await SharedPreferences.getInstance();
    final reported = prefs.getStringList(StorageValues.reportedSirenIds) ?? [];

    if (!reported.contains(sirenId)) {
      reported.add(sirenId);
      await prefs.setStringList(StorageValues.reportedSirenIds, reported);
    }

    // state에서 해당 사이렌 제거
    final updatedList = state.sirenList
        .where((siren) => siren.id != sirenId)
        .toList();

    emit(state.copyWith(
      reportedSirenIds: reported.toSet(),
      sirenList: updatedList,
    ));
  }

  /// 차단된 사용자 ID 목록 로드
  Future<void> loadBlockedUserIds() async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList(StorageValues.blockedUserIds) ?? [];
    emit(state.copyWith(blockedUserIds: blocked.toSet()));
  }

  /// 사용자 차단 처리
  Future<void> blockUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList(StorageValues.blockedUserIds) ?? [];

    if (!blocked.contains(userId)) {
      blocked.add(userId);
      await prefs.setStringList(StorageValues.blockedUserIds, blocked);
    }

    // state에서 해당 유저의 사이렌 제거
    final updatedList = state.sirenList
        .where((siren) => siren.author?.userId != userId)
        .toList();

    emit(state.copyWith(
      blockedUserIds: blocked.toSet(),
      sirenList: updatedList,
    ));
  }
}

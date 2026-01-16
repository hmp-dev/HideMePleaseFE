import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'dart:async';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/app/core/injection/injection.dart';

@lazySingleton
class LiveActivityService {
  static const _channel = MethodChannel('com.hidemeplease/live_activity');
  Timer? _pollingTimer;
  String? _currentSpaceId;
  String? _checkedInAt;
  int? _maxCapacity;

  LiveActivityService() {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
  }

  /// Live Activity 시작 및 Push Token 반환
  /// Returns: Push Token (hex string) 또는 null
  Future<String?> startCheckInActivity({
    required String spaceName,
    required String spaceId,
    required int currentMembers,
    required int requiredMembers,
    required String checkedInAt,
    int? maxCapacity,
  }) async {
    print('🔵 [Flutter] Starting Live Activity...');
    print('🔵 [Flutter] Space Name: $spaceName, Space ID: $spaceId');
    print('🔵 [Flutter] Current Members: $currentMembers, Required: $requiredMembers');

    if (!Platform.isIOS) {
      print('⚠️ [Flutter] Not iOS platform, skipping');
      return null;
    }

    _currentSpaceId = spaceId;
    _checkedInAt = checkedInAt;
    _maxCapacity = maxCapacity;

    // 재시도 로직
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        retryCount++;
        print('🔵 [Flutter] Attempt $retryCount/$maxRetries - Invoking native method: startCheckInActivity');

        final result = await _channel.invokeMethod('startCheckInActivity', {
          'spaceName': spaceName,
          'spaceId': spaceId,
          'currentMembers': currentMembers,
          'requiredMembers': requiredMembers,
          'checkedInAt': checkedInAt,
        });

        print('✅ [Flutter] Native method returned: $result');

        if (result != null && result is String) {
          // Push Token 반환됨
          print('✅ [Flutter] Push Token received: $result');
          // 폴링 시작 (fallback)
          _startPolling(spaceId, checkedInAt);
          return result;
        } else if (result == null) {
          // Token은 없지만 Activity는 시작됨
          print('⚠️ [Flutter] Live Activity started but no Push Token');
          _startPolling(spaceId, checkedInAt);
          return null;
        } else if (retryCount < maxRetries) {
          print('⚠️ [Flutter] Live Activity failed, retrying after delay...');
          await Future.delayed(Duration(seconds: retryCount));
        }

      } catch (e) {
        print('❌ [Flutter] Error on attempt $retryCount: $e');

        if (retryCount >= maxRetries) {
          print('❌ [Flutter] All attempts failed to start Live Activity');
          return null;
        } else {
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }

    return null;
  }

  /// Live Activity 상태 업데이트 (폴링 fallback용)
  Future<bool> updateCheckInActivity({
    required String groupProgress,
    required int currentMembers,
    required int requiredMembers,
    required String checkedInAt,
    required int elapsedMinutes,
    required bool isCompleted,
    int? bonusPoints,
  }) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _channel.invokeMethod('updateCheckInActivity', {
        'groupProgress': groupProgress,
        'currentMembers': currentMembers,
        'requiredMembers': requiredMembers,
        'checkedInAt': checkedInAt,
        'elapsedMinutes': elapsedMinutes,
        'isCompleted': isCompleted,
        'bonusPoints': bonusPoints,
      });
      return result == true;
    } catch (e) {
      print('Error updating Live Activity: $e');
      return false;
    }
  }

  Future<bool> endCheckInActivity() async {
    if (!Platform.isIOS) return false;

    // 폴링 타이머 정지
    _stopPolling();

    try {
      final result = await _channel.invokeMethod('endCheckInActivity');
      return result == true;
    } catch (e) {
      print('Error ending Live Activity: $e');
      return false;
    }
  }

  /// 모든 stale Live Activity 정리 (앱 시작 시 호출)
  Future<bool> endAllActivities() async {
    if (!Platform.isIOS) return false;

    try {
      print('🔵 [Flutter] Ending all stale Live Activities...');
      final result = await _channel.invokeMethod('endAllActivities');
      print('✅ [Flutter] All stale activities ended');
      return result == true;
    } catch (e) {
      print('Error ending all Live Activities: $e');
      return false;
    }
  }

  // 백엔드 폴링 시작 (15초 간격, Push fallback용)
  void _startPolling(String spaceId, String checkedInAt) {
    _currentSpaceId = spaceId;
    _checkedInAt = checkedInAt;
    _stopPolling(); // 기존 타이머 정리

    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _fetchCheckInStatus();
    });

    // 즉시 한 번 실행
    _fetchCheckInStatus();
  }

  // 폴링 정지
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // 백엔드에서 체크인 상태 가져오기
  Future<void> _fetchCheckInStatus() async {
    if (_currentSpaceId == null) return;

    try {
      final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
      final response = await spaceRemoteDataSource.getCheckInUsers(
        spaceId: _currentSpaceId!,
      );

      final currentMembers = response.currentGroup?.members?.length ?? 0;

      // map_info_card.dart와 동일한 로직으로 requiredMembers 계산
      int requiredMembers = (_maxCapacity != null && _maxCapacity! > 0) ? _maxCapacity! : 5;
      final progress = response.currentGroup?.progress ?? '';
      if (progress.isNotEmpty) {
        final parts = progress.split('/');
        if (parts.length == 2) {
          // maxCapacity가 없거나 0이면 progress에서 파싱
          if (_maxCapacity == null || _maxCapacity == 0) {
            requiredMembers = int.tryParse(parts[1]) ?? 5;
          }
        }
      }

      final groupProgress = '$currentMembers/$requiredMembers';
      final isCompleted = response.currentGroup?.isCompleted ?? false;
      final bonusPoints = response.currentGroup?.bonusPoints;

      // 경과 시간 계산
      int elapsedMinutes = 0;
      if (_checkedInAt != null) {
        try {
          final checkedInTime = DateTime.parse(_checkedInAt!);
          elapsedMinutes = DateTime.now().difference(checkedInTime).inMinutes;
        } catch (_) {}
      }

      print('📊 [Polling] Progress: $groupProgress, Completed: $isCompleted');

      // Live Activity 종료 조건 체크
      final shouldEndActivity = isCompleted ||
          response.currentGroup == null ||
          (response.currentGroup?.members?.isEmpty ?? false) ||
          currentMembers == 0;

      if (shouldEndActivity) {
        print('🎉 [Polling] Matching completed! Ending Live Activity...');
        await endCheckInActivity();
      } else {
        // Live Activity 업데이트
        await updateCheckInActivity(
          groupProgress: groupProgress,
          currentMembers: currentMembers,
          requiredMembers: requiredMembers,
          checkedInAt: _checkedInAt ?? DateTime.now().toIso8601String(),
          elapsedMinutes: elapsedMinutes,
          isCompleted: false,
          bonusPoints: bonusPoints,
        );
      }

    } catch (e) {
      print('❌ [Polling] Error fetching check-in status: $e');
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    print('📲 [Flutter Callback] Received from native: ${call.method}');
    switch (call.method) {
      case 'liveActivityStarted':
        print('✅ [Flutter Callback] Live Activity started with ID: ${call.arguments}');
        break;
      case 'liveActivityError':
        print('❌ [Flutter Callback] Live Activity error: ${call.arguments}');
        break;
      case 'liveActivityExpired':
        print('⏰ [Flutter Callback] Live Activity expired');
        break;
      default:
        print('❓ [Flutter Callback] Unknown method: ${call.method}');
    }
  }
}
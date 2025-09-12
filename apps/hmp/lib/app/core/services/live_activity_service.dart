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
  
  LiveActivityService() {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
  }
  
  Future<bool> startCheckInActivity({
    required String spaceName,
    required int currentUsers,
    required int remainingUsers,
    required int maxCapacity,
    String? spaceId,
  }) async {
    print('🔵 [Flutter] Starting Live Activity...');
    print('🔵 [Flutter] Space Name: $spaceName');
    print('🔵 [Flutter] Current Users: $currentUsers');
    print('🔵 [Flutter] Remaining Users: $remainingUsers');
    print('🔵 [Flutter] Max Capacity: $maxCapacity');
    
    if (!Platform.isIOS) {
      print('⚠️ [Flutter] Not iOS platform, skipping');
      return false;
    }
    
    // 재시도 로직 추가
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        retryCount++;
        print('🔵 [Flutter] Attempt $retryCount/$maxRetries - Invoking native method: startCheckInActivity');
        
        final result = await _channel.invokeMethod('startCheckInActivity', {
          'spaceName': spaceName,
          'currentUsers': currentUsers,
          'remainingUsers': remainingUsers,
          'maxCapacity': maxCapacity,
        });
        
        print('✅ [Flutter] Native method returned: $result');
        
        if (result == true) {
          // 폴링 시작 (spaceId가 제공된 경우)
          if (spaceId != null) {
            _startPolling(spaceId);
          }
          return true;
        } else if (retryCount < maxRetries) {
          print('⚠️ [Flutter] Live Activity failed, retrying after delay...');
          await Future.delayed(Duration(seconds: retryCount)); // 점진적 지연
        }
        
      } catch (e) {
        print('❌ [Flutter] Error on attempt $retryCount: $e');
        
        if (retryCount >= maxRetries) {
          print('❌ [Flutter] All attempts failed to start Live Activity');
          print('❌ [Flutter] Final error: $e');
          print('❌ [Flutter] Stack trace: ${StackTrace.current}');
          return false;
        } else {
          print('⚠️ [Flutter] Retrying after delay...');
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
    
    return false;
  }
  
  Future<bool> updateCheckInActivity({
    required bool isConfirmed,
  }) async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _channel.invokeMethod('updateCheckInActivity', {
        'isConfirmed': isConfirmed,
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
  
  // 백엔드 폴링 시작 (15초 간격으로 단축)
  void _startPolling(String spaceId) {
    _currentSpaceId = spaceId;
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
    _currentSpaceId = null;
  }
  
  // 백엔드에서 체크인 상태 가져오기
  Future<void> _fetchCheckInStatus() async {
    if (_currentSpaceId == null) return;
    
    try {
      // 실제 백엔드 API 호출
      final spaceRemoteDataSource = getIt<SpaceRemoteDataSource>();
      final response = await spaceRemoteDataSource.getCheckInUsers(
        spaceId: _currentSpaceId!,
      );
      
      // currentGroup.members.length로 현재 인원 계산
      final currentUsers = response.currentGroup?.members?.length ?? 0;
      final remainingUsers = 5 - currentUsers; // 최대 5명
      
      print('📊 [Polling] Updating Live Activity - Current: $currentUsers, Remaining: $remainingUsers');
      print('📊 [Polling] Group completed: ${response.currentGroup?.isCompleted}');
      print('📊 [Polling] Current group: ${response.currentGroup != null ? "exists" : "null"}');
      print('📊 [Polling] Members count: ${response.currentGroup?.members?.length ?? 0}');
      
      // Live Activity 종료 조건 체크:
      // 1. currentGroup이 완료됨 (isCompleted == true)
      // 2. currentGroup이 null (매칭 완료 후 리셋됨)
      // 3. currentGroup.members가 비어있음 (새 그룹 시작)
      // 4. currentUsers가 0 (아무도 체크인하지 않음 - 리셋된 상태)
      final shouldEndActivity = response.currentGroup?.isCompleted == true || 
                                response.currentGroup == null ||
                                (response.currentGroup?.members?.isEmpty ?? false) ||
                                currentUsers == 0;
      
      if (shouldEndActivity) {
        print('🎉 [Polling] Matching completed or group reset! Ending Live Activity...');
        print('   - isCompleted: ${response.currentGroup?.isCompleted}');
        print('   - currentGroup is null: ${response.currentGroup == null}');
        print('   - members is empty: ${response.currentGroup?.members?.isEmpty ?? false}');
        print('   - currentUsers is 0: ${currentUsers == 0}');
        await endCheckInActivity();
      } else {
        // Live Activity가 계속되어야 하는 경우에만 업데이트
        await _channel.invokeMethod('updateCheckInNumbers', {
          'currentUsers': currentUsers,
          'remainingUsers': remainingUsers,
        });
      }
      
    } catch (e) {
      print('❌ [Polling] Error fetching check-in status: $e');
      // 에러 발생 시에도 계속 폴링 (네트워크 일시적 문제일 수 있음)
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
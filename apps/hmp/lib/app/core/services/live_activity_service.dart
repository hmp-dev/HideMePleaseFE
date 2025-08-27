import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'dart:async';
import 'package:mobile/features/space/infrastructure/data_sources/space_remote_data_source.dart';
import 'package:mobile/app/core/get_it/get_it.dart';

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
    String? spaceId,
  }) async {
    print('🔵 [Flutter] Starting Live Activity...');
    print('🔵 [Flutter] Space Name: $spaceName');
    print('🔵 [Flutter] Current Users: $currentUsers');
    print('🔵 [Flutter] Remaining Users: $remainingUsers');
    
    if (!Platform.isIOS) {
      print('⚠️ [Flutter] Not iOS platform, skipping');
      return false;
    }
    
    try {
      print('🔵 [Flutter] Invoking native method: startCheckInActivity');
      final result = await _channel.invokeMethod('startCheckInActivity', {
        'spaceName': spaceName,
        'currentUsers': currentUsers,
        'remainingUsers': remainingUsers,
      });
      print('✅ [Flutter] Native method returned: $result');
      
      // 폴링 시작 (spaceId가 제공된 경우)
      if (result == true && spaceId != null) {
        _startPolling(spaceId);
      }
      
      return result == true;
    } catch (e) {
      print('❌ [Flutter] Error starting Live Activity: $e');
      print('❌ [Flutter] Stack trace: ${StackTrace.current}');
      return false;
    }
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
  
  // 백엔드 폴링 시작 (30초 간격)
  void _startPolling(String spaceId) {
    _currentSpaceId = spaceId;
    _stopPolling(); // 기존 타이머 정리
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
      
      // Native 메서드 호출하여 Live Activity 업데이트
      await _channel.invokeMethod('updateCheckInNumbers', {
        'currentUsers': currentUsers,
        'remainingUsers': remainingUsers,
      });
      
      // 매칭 완료 시 Live Activity 자동 종료
      if (response.currentGroup?.isCompleted == true) {
        print('🎉 [Polling] Group completed! Ending Live Activity...');
        await endCheckInActivity();
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
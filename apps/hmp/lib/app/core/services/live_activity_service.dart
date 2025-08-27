import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

@lazySingleton
class LiveActivityService {
  static const _channel = MethodChannel('com.hidemeplease/live_activity');
  
  LiveActivityService() {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
    }
  }
  
  Future<bool> startCheckInActivity({
    required String spaceName,
    required int currentUsers,
    required int remainingUsers,
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
    
    try {
      final result = await _channel.invokeMethod('endCheckInActivity');
      return result == true;
    } catch (e) {
      print('Error ending Live Activity: $e');
      return false;
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
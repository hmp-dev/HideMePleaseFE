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
    required String benefit,
  }) async {
    if (!Platform.isIOS) return false;
    
    try {
      final result = await _channel.invokeMethod('startCheckInActivity', {
        'spaceName': spaceName,
        'benefit': benefit,
      });
      return result == true;
    } catch (e) {
      print('Error starting Live Activity: $e');
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
    switch (call.method) {
      case 'liveActivityStarted':
        print('Live Activity started with ID: ${call.arguments}');
        break;
      case 'liveActivityError':
        print('Live Activity error: ${call.arguments}');
        break;
      case 'liveActivityExpired':
        print('Live Activity expired');
        break;
      default:
        print('Unknown method: ${call.method}');
    }
  }
}
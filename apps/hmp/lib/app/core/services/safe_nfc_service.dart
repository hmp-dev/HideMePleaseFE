import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:io' show Platform;

class SafeNfcService {
  // 싱글톤 방지 - 매번 새 인스턴스 생성
  SafeNfcService._();
  
  static Future<void> startReading({
    required BuildContext context,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    print('🟦 SafeNfcService: Starting NFC reading...');
    
    try {
      // 1. NFC 가용성 확인
      final isAvailable = await NfcManager.instance.isAvailable();
      print('🟦 NFC available: $isAvailable');
      
      if (!isAvailable) {
        onError('NFC를 사용할 수 없습니다. 설정을 확인해주세요.');
        return;
      }
      
      // 2. iOS 전용 처리
      if (Platform.isIOS) {
        print('🟦 iOS detected - using iOS-specific NFC session');
        
        // 기존 세션 정리 (에러 무시)
        try {
          await NfcManager.instance.stopSession();
          print('🟦 Cleaned up previous session');
        } catch (_) {
          // 무시
        }
        
        // 대기
        await Future.delayed(Duration(milliseconds: 500));
        
        // 새 세션 시작
        try {
          print('🟦 Starting new iOS NFC session...');
          print('🟦 Device info: ${Platform.operatingSystemVersion}');
          print('🟦 Starting session with polling options: iso14443, iso15693');
          
          await NfcManager.instance.startSession(
            pollingOptions: {
              NfcPollingOption.iso14443,
              NfcPollingOption.iso15693,
            },
            alertMessage: 'NFC 태그를 가까이 대주세요',
            onDiscovered: (NfcTag tag) async {
              print('🟢 NFC Tag discovered!');
              print('🟢 Tag data keys: ${tag.data.keys}');
              
              String tagId = 'Unknown';
              
              try {
                // iOS 태그 ID 추출
                if (tag.data.containsKey('mifare')) {
                  final mifare = tag.data['mifare'];
                  if (mifare != null && mifare['identifier'] != null) {
                    final identifier = mifare['identifier'] as List<int>;
                    tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();

                    print('🟢 Tag ID: $tagId');
                  }
                } else if (tag.data.containsKey('iso15693')) {
                  // ISO15693 태그 처리 추가
                  final iso15693 = tag.data['iso15693'];
                  if (iso15693 != null && iso15693['identifier'] != null) {
                    final identifier = iso15693['identifier'] as List<int>;
                    tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                  }
                } else if (tag.data.containsKey('feliCa')) {
                  // FeliCa 태그 처리 추가
                  final feliCa = tag.data['feliCa'];
                  if (feliCa != null && feliCa['currentIDm'] != null) {
                    final identifier = feliCa['currentIDm'] as List<int>;
                    tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                  }
                }
              } catch (e) {
                // 태그 ID 추출 실패시 기본값 유지
              }
              
              // 세션 종료
              await NfcManager.instance.stopSession(
                alertMessage: '체크인 완료!'
              );
              
              onSuccess(tagId);
            },
            onError: (error) async {
              print('🔴 NFC Error occurred');
              print('🔴 Error type: ${error.runtimeType}');
              print('🔴 Error: $error');
              
              if (error is NfcError) {
                print('🔴 NfcError.type: ${error.type}');
                print('🔴 NfcError.message: ${error.message}');
                print('🔴 NfcError.details: ${error.details}');
                
                // 구체적인 에러 메시지 처리
                switch (error.type) {
                  case NfcErrorType.sessionTimeout:
                    onError('NFC 세션이 시간초과되었습니다.');
                    break;
                  case NfcErrorType.userCanceled:
                    onError('사용자가 NFC 읽기를 취소했습니다.');
                    break;
                  case NfcErrorType.systemIsBusy:
                    onError('시스템이 바쁩니다. 잠시 후 다시 시도해주세요.');
                    break;
                  default:
                    if (error.message?.contains('Missing required entitlement') == true) {
                      onError('NFC 권한이 없습니다. 앱을 다시 설치해주세요.');
                    } else {
                      onError('NFC 오류: ${error.message ?? "알 수 없음"}');
                    }
                }
              } else {
                onError('알 수 없는 오류');
              }
            },
          );
          
          print('🟦 iOS NFC session started successfully');
        } catch (e) {
          print('🔴 Failed to start iOS NFC session: $e');
          onError('NFC 시작 실패: ${e.toString()}');
        }
      } else {
        // Android 처리
        print('🟦 Android detected - using Android NFC session');
        
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            print('🟢 NFC Tag discovered on Android!');
            
            String tagId = 'Unknown';
            
            // Android 태그 ID 추출
            if (tag.data.containsKey('nfca')) {
              final nfca = tag.data['nfca'];
              if (nfca != null && nfca['identifier'] != null) {
                final identifier = nfca['identifier'] as List<int>;
                tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              }
            }
            
            await NfcManager.instance.stopSession();
            onSuccess(tagId);
          },
        );
      }
    } catch (e) {
      print('🔴 Unexpected error: $e');
      onError('예기치 않은 오류: ${e.toString()}');
    }
  }
}
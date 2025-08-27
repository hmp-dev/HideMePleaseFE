import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:io' show Platform;

class SimpleNfcTest {
  static Future<void> testNfc(BuildContext context) async {
    print('🔵 Starting simple NFC test...');
    
    // 매번 새로운 인스턴스를 사용하도록 수정
    final nfcManager = NfcManager.instance;
    
    try {
      // 1. 기존 세션이 있으면 강제 종료
      try {
        await nfcManager.stopSession();
        print('🔵 Forced stop of any existing session');
      } catch (e) {
        print('🔵 No session to stop or error: $e');
      }
      
      // 2. 충분한 대기 시간
      await Future.delayed(Duration(seconds: 1));
      
      // 3. NFC 가용성 체크
      bool isAvailable = await nfcManager.isAvailable();
      print('🔵 NFC Available: $isAvailable');
      
      if (!isAvailable) {
        _showMessage(context, 'NFC not available on this device');
        return;
      }
      
      // 4. 새 세션 시작
      print('🔵 Starting new NFC session...');
      
      if (Platform.isIOS) {
        // iOS용 세션 - 새로운 인스턴스 사용
        await nfcManager.startSession(
          alertMessage: 'Hold your iPhone near the NFC tag',
          onDiscovered: (NfcTag tag) async {
            print('🟢 Tag discovered!');
            print('🟢 Tag data: ${tag.data}');
            
            // 세션 종료 - 같은 인스턴스 사용
            await nfcManager.stopSession(
              alertMessage: 'Success!'
            );
            
            _showMessage(context, 'NFC Tag detected successfully!');
          },
          onError: (error) async {
            print('🔴 Session error: $error');
            print('🔴 Error type: ${error.runtimeType}');
            
            if (error is NfcError) {
              print('🔴 NfcError.type: ${error.type}');
              print('🔴 NfcError.message: ${error.message}');
              print('🔴 NfcError.details: ${error.details}');
              
              String errorMsg = 'NFC Error: ';
              
              // enum을 문자열로 변환하여 비교
              String errorTypeStr = error.type.toString();
              
              if (errorTypeStr.contains('unknown')) {
                errorMsg += 'Unknown error';
              } else if (errorTypeStr.contains('unsupported')) {
                errorMsg += 'NFC not supported';
              } else if (errorTypeStr.contains('disabled')) {
                errorMsg += 'NFC is disabled';
              } else if (errorTypeStr.contains('invalidParameter')) {
                errorMsg += 'Invalid parameter';
              } else if (errorTypeStr.contains('userCanceled')) {
                errorMsg += 'User canceled';
              } else if (errorTypeStr.contains('timeout')) {
                errorMsg += 'Timeout';
              } else if (errorTypeStr.contains('systemIsBusy')) {
                errorMsg += 'System is busy';
              } else {
                errorMsg += errorTypeStr;
              }
              
              if (error.message != null) {
                errorMsg += ' - ${error.message}';
              }
              
              _showMessage(context, errorMsg);
            } else {
              _showMessage(context, 'Error: ${error.toString()}');
            }
          },
        );
        
        print('🔵 iOS NFC session started successfully');
      } else {
        // Android용 세션
        await nfcManager.startSession(
          onDiscovered: (NfcTag tag) async {
            print('🟢 Tag discovered!');
            await nfcManager.stopSession();
            _showMessage(context, 'NFC Tag detected!');
          },
        );
      }
      
    } catch (e, stackTrace) {
      print('🔴 Fatal error: $e');
      print('🔴 Error type: ${e.runtimeType}');
      print('🔴 Stack trace: $stackTrace');
      
      String errorMessage = '';
      
      if (e is NfcError) {
        print('🔴 Caught NfcError in catch block');
        print('🔴 NfcError.type: ${e.type}');
        print('🔴 NfcError.message: ${e.message}');
        print('🔴 NfcError.details: ${e.details}');
        
        String errorTypeStr = e.type.toString();
        
        if (errorTypeStr.contains('unknown')) {
          errorMessage = 'Unknown NFC error occurred';
        } else if (errorTypeStr.contains('unsupported')) {
          errorMessage = 'This device does not support NFC';
        } else if (errorTypeStr.contains('disabled')) {
          errorMessage = 'NFC is disabled. Please enable it in Settings';
        } else if (errorTypeStr.contains('invalidParameter')) {
          errorMessage = 'Invalid NFC parameter';
        } else if (errorTypeStr.contains('userCanceled')) {
          errorMessage = 'NFC scan was canceled';
        } else if (errorTypeStr.contains('timeout')) {
          errorMessage = 'NFC scan timed out';
        } else if (errorTypeStr.contains('systemIsBusy')) {
          errorMessage = 'NFC system is busy. Try again';
        } else {
          errorMessage = 'NFC Error: ${e.type}';
        }
        
        if (e.message != null && e.message!.isNotEmpty) {
          errorMessage += '\nDetails: ${e.message}';
        }
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      _showMessage(context, errorMessage);
    }
  }
  
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'dart:io' show Platform;

class NfcService {
  static final NfcService _instance = NfcService._internal();
  factory NfcService() => _instance;
  NfcService._internal();

  // NFC 사용 가능 여부 확인
  Future<bool> isNfcAvailable() async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      ('🔍 NFC Available: $isAvailable').log();
      return isAvailable;
    } catch (e) {
      ('❌ Error checking NFC availability: $e').log();
      return false;
    }
  }

  // NFC 태그 읽기 시작
  Future<void> startNfcReading({
    required Function(String) onTagRead,
    required Function(String) onError,
    BuildContext? context,
  }) async {
    try {
      // NFC 사용 가능 여부 확인
      final isAvailable = await isNfcAvailable();
      if (!isAvailable) {
        onError('NFC를 사용할 수 없습니다. 기기 설정을 확인해주세요.');
        return;
      }

      ('🚀 Starting NFC tag reading...').log();
      
      // 기존 세션이 있으면 먼저 종료
      try {
        await NfcManager.instance.stopSession();
        ('✅ Previous NFC session stopped').log();
        // iOS에서는 세션 종료 후 잠시 대기
        if (Platform.isIOS) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        // 세션이 없는 경우 무시
        ('ℹ️ No previous session to stop').log();
      }
      
      // 안드로이드에서는 커스텀 다이얼로그 표시
      if (context != null && Platform.isAndroid) {
        _showAndroidNfcDialog(context);
      }
      
      // iOS에서는 alertMessage와 함께 세션 시작
      if (Platform.isIOS) {
        ('📱 Starting iOS NFC session...').log();
        
        // iOS에서 NFC 권한 확인
        try {
          final bool isNfcSupported = await NfcManager.instance.isAvailable();
          if (!isNfcSupported) {
            onError('이 iPhone은 NFC를 지원하지 않습니다');
            return;
          }
        } catch (e) {
          ('⚠️ Failed to check NFC support: $e').log();
        }
        
        try {
          await NfcManager.instance.startSession(
            alertMessage: 'NFC 태그를 가까이 대주세요',
            onDiscovered: (NfcTag tag) async {
            try {
              ('✅ NFC Tag discovered!').log();
              ('📱 Tag data: ${tag.data}').log();
              
              // NFC 태그 ID 추출
              String tagId = '';
              
              // iOS의 경우 - 다양한 태그 타입 처리
              if (tag.data.containsKey('mifare')) {
                final mifare = tag.data['mifare'];
                if (mifare != null && mifare['identifier'] != null) {
                  final identifier = mifare['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              } else if (tag.data.containsKey('iso7816')) {
                final iso7816 = tag.data['iso7816'];
                if (iso7816 != null && iso7816['identifier'] != null) {
                  final identifier = iso7816['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              } else if (tag.data.containsKey('iso15693')) {
                final iso15693 = tag.data['iso15693'];
                if (iso15693 != null && iso15693['identifier'] != null) {
                  final identifier = iso15693['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              } else if (tag.data.containsKey('feliCa')) {
                final feliCa = tag.data['feliCa'];
                if (feliCa != null && feliCa['identifier'] != null) {
                  final identifier = feliCa['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              }

              if (tagId.isNotEmpty) {
                ('🏷️ Tag ID: $tagId').log();
                onTagRead(tagId);
              } else {
                ('⚠️ Unable to extract tag ID').log();
                onError('태그 ID를 읽을 수 없습니다.');
              }

              // 세션 종료 (성공 메시지와 함께)
              await NfcManager.instance.stopSession(alertMessage: '체크인 완료!');
            } catch (e) {
              ('❌ Error processing NFC tag: $e').log();
              onError('태그 처리 중 오류가 발생했습니다: $e');
              await NfcManager.instance.stopSession(errorMessage: '태그 읽기 실패');
            }
            },
            onError: (error) async {
              ('❌ NFC Session error: $error').log();
            ('❌ Error type: ${error.runtimeType}').log();
            ('❌ Error details: ${error.toString()}').log();
            
            String errorMessage = 'NFC 오류가 발생했습니다';
            
            // NfcError의 details 확인
            try {
              if (error is NfcError) {
                ('❌ NfcError type: ${error.type}').log();
                ('❌ NfcError message: ${error.message}').log();
                
                // NfcErrorType enum values from nfc_manager package
                final errorTypeStr = error.type.toString();
                ('❌ NfcError type string: $errorTypeStr').log();
                
                if (errorTypeStr.contains('unknown')) {
                  errorMessage = 'NFC 오류: 알 수 없는 오류';
                } else if (errorTypeStr.contains('unavailable')) {
                  errorMessage = 'NFC를 사용할 수 없습니다';
                } else if (errorTypeStr.contains('disabled')) {
                  errorMessage = 'NFC가 비활성화되어 있습니다. 설정에서 활성화해주세요';
                } else if (errorTypeStr.contains('invalidParameter')) {
                  errorMessage = 'NFC 파라미터 오류';
                } else if (errorTypeStr.contains('userCanceled')) {
                  errorMessage = '사용자가 NFC 읽기를 취소했습니다';
                } else if (errorTypeStr.contains('timeout')) {
                  errorMessage = 'NFC 세션 시간이 초과되었습니다';
                } else if (errorTypeStr.contains('systemIsBusy')) {
                  errorMessage = 'NFC가 사용 중입니다. 잠시 후 다시 시도해주세요';
                } else {
                  errorMessage = 'NFC 오류: ${error.message ?? errorTypeStr}';
                }
              }
            } catch (e) {
              ('❌ Error parsing NfcError: $e').log();
            }
            
            onError(errorMessage);
            return;
          },
        );
        } catch (e) {
          ('❌ Error starting iOS NFC session: $e').log();
          onError('iOS NFC 세션 시작 실패: ${e.toString()}');
        }
      } 
      // Android의 경우
      else {
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            try {
              ('✅ NFC Tag discovered!').log();
              ('📱 Tag data: ${tag.data}').log();
              
              // NFC 태그 ID 추출
              String tagId = '';
              
              // Android의 경우
              if (tag.data.containsKey('nfca')) {
                final nfca = tag.data['nfca'];
                if (nfca != null && nfca['identifier'] != null) {
                  final identifier = nfca['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              } else if (tag.data.containsKey('ndef')) {
                final ndef = tag.data['ndef'];
                if (ndef != null && ndef['identifier'] != null) {
                  final identifier = ndef['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                }
              }

              if (tagId.isNotEmpty) {
                ('🏷️ Tag ID: $tagId').log();
                
                // 안드로이드 다이얼로그 닫기
                if (context != null) {
                  Navigator.of(context).pop();
                }
                
                onTagRead(tagId);
              } else {
                ('⚠️ Unable to extract tag ID').log();
                
                // 안드로이드 다이얼로그 닫기
                if (context != null) {
                  Navigator.of(context).pop();
                }
                
                onError('태그 ID를 읽을 수 없습니다.');
              }

              // 세션 종료
              await NfcManager.instance.stopSession();
            } catch (e) {
              ('❌ Error processing NFC tag: $e').log();
              onError('태그 처리 중 오류가 발생했습니다: $e');
              await NfcManager.instance.stopSession(errorMessage: e.toString());
            }
          },
          onError: (error) async {
            ('❌ NFC Session error: $error').log();
            ('❌ Error type: ${error.runtimeType}').log();
            ('❌ Error details: ${error.toString()}').log();
            
            String errorMessage = 'NFC 오류가 발생했습니다';
            
            // NfcError의 details 확인
            try {
              if (error is NfcError) {
                ('❌ NfcError type: ${error.type}').log();
                ('❌ NfcError message: ${error.message}').log();
                
                // NfcErrorType enum values from nfc_manager package
                final errorTypeStr = error.type.toString();
                ('❌ NfcError type string: $errorTypeStr').log();
                
                if (errorTypeStr.contains('unknown')) {
                  errorMessage = 'NFC 오류: 알 수 없는 오류';
                } else if (errorTypeStr.contains('unavailable')) {
                  errorMessage = 'NFC를 사용할 수 없습니다';
                } else if (errorTypeStr.contains('disabled')) {
                  errorMessage = 'NFC가 비활성화되어 있습니다. 설정에서 활성화해주세요';
                } else if (errorTypeStr.contains('invalidParameter')) {
                  errorMessage = 'NFC 파라미터 오류';
                } else if (errorTypeStr.contains('userCanceled')) {
                  errorMessage = '사용자가 NFC 읽기를 취소했습니다';
                } else if (errorTypeStr.contains('timeout')) {
                  errorMessage = 'NFC 세션 시간이 초과되었습니다';
                } else if (errorTypeStr.contains('systemIsBusy')) {
                  errorMessage = 'NFC가 사용 중입니다. 잠시 후 다시 시도해주세요';
                } else {
                  errorMessage = 'NFC 오류: ${error.message ?? errorTypeStr}';
                }
              }
            } catch (e) {
              ('❌ Error parsing NfcError: $e').log();
            }
            
            onError(errorMessage);
            return;
          },
        );
      }
      
    } catch (e) {
      ('❌ Error starting NFC session: $e').log();
      String errorMessage = 'NFC 세션 시작 실패';
      
      if (e.toString().contains('NfcError')) {
        if (e.toString().contains('NotAvailable')) {
          errorMessage = 'NFC를 사용할 수 없습니다. 기기가 NFC를 지원하는지 확인해주세요';
        } else if (e.toString().contains('Disabled')) {
          errorMessage = 'NFC가 꺼져있습니다. 설정 > NFC에서 활성화해주세요';
        } else if (e.toString().contains('UserCancel')) {
          errorMessage = '사용자가 NFC 읽기를 취소했습니다';
        } else {
          errorMessage = 'NFC 오류: ${e.toString()}';
        }
      }
      
      // 안드로이드 다이얼로그가 열려있다면 닫기
      if (context != null && Platform.isAndroid) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      onError(errorMessage);
    }
  }

  // NFC 세션 중지
  Future<void> stopNfcReading() async {
    try {
      ('🛑 Stopping NFC session...').log();
      await NfcManager.instance.stopSession();
      ('✅ NFC session stopped').log();
    } catch (e) {
      ('❌ Error stopping NFC session: $e').log();
    }
  }

  // Android용 NFC 다이얼로그 표시
  void _showAndroidNfcDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF19BAFF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF19BAFF).withOpacity(0.2),
                        const Color(0xFF19BAFF).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.nfc,
                    color: Color(0xFF19BAFF),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'NFC 태그 읽기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'NFC 태그를 기기 뒷면에 가까이 대주세요',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // 로딩 인디케이터
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19BAFF)),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    stopNfcReading();
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xFF19BAFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NFC 태그에 데이터 쓰기 (선택적 기능)
  Future<void> writeToNfcTag({
    required String data,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final isAvailable = await isNfcAvailable();
      if (!isAvailable) {
        onError('NFC를 사용할 수 없습니다.');
        return;
      }

      ('📝 Starting NFC tag writing...').log();
      
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Ndef 쓰기 지원 확인
            final ndef = Ndef.from(tag);
            if (ndef == null || !ndef.isWritable) {
              onError('이 태그는 쓰기를 지원하지 않습니다.');
              await NfcManager.instance.stopSession(errorMessage: '쓰기 불가능한 태그');
              return;
            }

            // NdefMessage 생성
            final message = NdefMessage([
              NdefRecord.createText(data),
            ]);

            // 태그에 쓰기
            await ndef.write(message);
            ('✅ Successfully wrote to NFC tag').log();
            onSuccess();
            
            await NfcManager.instance.stopSession();
          } catch (e) {
            ('❌ Error writing to NFC tag: $e').log();
            onError('태그 쓰기 실패: $e');
            await NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        },
      );
    } catch (e) {
      ('❌ Error in writeToNfcTag: $e').log();
      onError('NFC 쓰기 실패: $e');
    }
  }
}
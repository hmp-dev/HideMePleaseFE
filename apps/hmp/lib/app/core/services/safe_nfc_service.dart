import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';

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
            alertMessage: LocaleKeys.nfc_tag_nearby.tr(),
            onDiscovered: (NfcTag tag) async {
              ('🟢 NFC Tag discovered!').log();
              ('🟢 Tag data keys: ${tag.data.keys}').log();
              
              String tagId = 'Unknown';
              
              // 먼저 NDEF 메시지에서 UUID 추출 시도
              try {
                final ndef = Ndef.from(tag);
                if (ndef != null) {
                  ('📝 NDEF available on tag').log();
                  
                  // cachedMessage가 있는지 확인
                  if (ndef.cachedMessage != null) {
                    ('📝 NDEF message found with ${ndef.cachedMessage!.records.length} records').log();
                    
                    for (final record in ndef.cachedMessage!.records) {
                      ('📋 Record type: ${record.typeNameFormat}').log();
                      ('📋 Record type bytes: ${record.type}').log();
                      ('📋 Record payload length: ${record.payload.length}').log();
                      
                      // Text 레코드 처리 (TNF = 1, Type = "T")
                      if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
                          record.type.length == 1 && record.type[0] == 0x54) { // 'T' for Text
                        final payload = record.payload;
                        if (payload.isNotEmpty) {
                          // NDEF Text 레코드는 첫 바이트가 상태 바이트 (언어 코드 길이 포함)
                          int languageCodeLength = payload[0] & 0x3F;
                          if (payload.length > languageCodeLength + 1) {
                            final text = String.fromCharCodes(
                              payload.sublist(languageCodeLength + 1)
                            );
                            ('📖 Text record found: $text').log();
                            
                            // UUID 패턴 확인 (예: aa490f44-e6af-45e1-8908-5b6a76386c28)
                            final uuidRegex = RegExp(
                              r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
                              caseSensitive: false
                            );
                            if (uuidRegex.hasMatch(text.trim())) {
                              tagId = text.trim();
                              ('✅ UUID found in NDEF: $tagId').log();
                              break;
                            }
                          }
                        }
                      }
                    }
                  } else {
                    ('⚠️ No cached NDEF message on tag').log();
                  }
                } else {
                  ('⚠️ NDEF not available on this tag').log();
                }
              } catch (e) {
                ('⚠️ Error reading NDEF: $e').log();
              }
              
              // NDEF에서 UUID를 찾지 못한 경우, 기존 방식으로 태그 ID 추출
              if (tagId == 'Unknown' || !tagId.contains('-')) {
                ('⚠️ No UUID in NDEF, falling back to tag hardware ID').log();
                
                try {
                  // iOS 태그 ID 추출
                  if (tag.data.containsKey('mifare')) {
                    final mifare = tag.data['mifare'];
                    if (mifare != null && mifare['identifier'] != null) {
                      final identifier = mifare['identifier'] as List<int>;
                      tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                      ('🟢 Hardware Tag ID: $tagId').log();
                    }
                  } else if (tag.data.containsKey('iso15693')) {
                    final iso15693 = tag.data['iso15693'];
                    if (iso15693 != null && iso15693['identifier'] != null) {
                      final identifier = iso15693['identifier'] as List<int>;
                      tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                    }
                  } else if (tag.data.containsKey('feliCa')) {
                    final feliCa = tag.data['feliCa'];
                    if (feliCa != null && feliCa['currentIDm'] != null) {
                      final identifier = feliCa['currentIDm'] as List<int>;
                      tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                    }
                  }
                } catch (e) {
                  ('❌ Error extracting hardware ID: $e').log();
                }
              }
              
              ('📍 Final tag data to return: $tagId').log();
              
              // 세션 종료
              await NfcManager.instance.stopSession(
                alertMessage: LocaleKeys.checkin_success.tr()
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
        ('🟦 Android detected - using Android NFC session').log();
        
        // 안드로이드에서는 커스텀 다이얼로그 표시
        _showAndroidNfcDialog(context, () {
          // 다이얼로그 취소 시 호출
          NfcManager.instance.stopSession();
          onError('NFC 읽기가 취소되었습니다.');
        });
        
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            ('🟢 NFC Tag discovered on Android!').log();
            ('🟢 Tag data keys: ${tag.data.keys}').log();
            
            String tagId = 'Unknown';
            
            // 먼저 NDEF 메시지에서 UUID 추출 시도
            try {
              final ndef = Ndef.from(tag);
              if (ndef != null) {
                ('📝 NDEF available on tag').log();
                
                // cachedMessage가 있는지 확인
                if (ndef.cachedMessage != null) {
                  ('📝 NDEF message found with ${ndef.cachedMessage!.records.length} records').log();
                  
                  for (final record in ndef.cachedMessage!.records) {
                    ('📋 Record type: ${record.typeNameFormat}').log();
                    ('📋 Record type bytes: ${record.type}').log();
                    ('📋 Record payload length: ${record.payload.length}').log();
                    
                    // Text 레코드 처리 (TNF = 1, Type = "T")
                    if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
                        record.type.length == 1 && record.type[0] == 0x54) { // 'T' for Text
                      final payload = record.payload;
                      if (payload.isNotEmpty) {
                        // NDEF Text 레코드는 첫 바이트가 상태 바이트 (언어 코드 길이 포함)
                        int languageCodeLength = payload[0] & 0x3F;
                        if (payload.length > languageCodeLength + 1) {
                          final text = String.fromCharCodes(
                            payload.sublist(languageCodeLength + 1)
                          );
                          ('📖 Text record found: $text').log();
                          
                          // UUID 패턴 확인 (예: aa490f44-e6af-45e1-8908-5b6a76386c28)
                          final uuidRegex = RegExp(
                            r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
                            caseSensitive: false
                          );
                          if (uuidRegex.hasMatch(text.trim())) {
                            tagId = text.trim();
                            ('✅ UUID found in NDEF: $tagId').log();
                            break;
                          }
                        }
                      }
                    }
                  }
                } else {
                  ('⚠️ No cached NDEF message on tag').log();
                }
              } else {
                ('⚠️ NDEF not available on this tag').log();
              }
            } catch (e) {
              ('⚠️ Error reading NDEF: $e').log();
            }
            
            // NDEF에서 UUID를 찾지 못한 경우, 기존 방식으로 태그 ID 추출
            if (tagId == 'Unknown' || !tagId.contains('-')) {
              ('⚠️ No UUID in NDEF, falling back to tag hardware ID').log();
              
              // Android 태그 ID 추출
              if (tag.data.containsKey('nfca')) {
                final nfca = tag.data['nfca'];
                if (nfca != null && nfca['identifier'] != null) {
                  final identifier = nfca['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                  ('🟢 Hardware Tag ID: $tagId').log();
                }
              } else if (tag.data.containsKey('ndef')) {
                final ndefData = tag.data['ndef'];
                if (ndefData != null && ndefData['identifier'] != null) {
                  final identifier = ndefData['identifier'] as List<int>;
                  tagId = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
                  ('🟢 Hardware Tag ID from NDEF: $tagId').log();
                }
              }
            }
            
            ('📍 Final tag data to return: $tagId').log();
            
            // 안드로이드 다이얼로그 닫기
            Navigator.of(context).pop();
            
            await NfcManager.instance.stopSession();
            onSuccess(tagId);
          },
          onError: (error) async {
            ('🔴 Android NFC Error: $error').log();
            
            // 다이얼로그 닫기
            try {
              Navigator.of(context).pop();
            } catch (_) {
              // 다이얼로그가 이미 닫혔을 수 있음
            }
            
            onError('NFC 읽기 중 오류가 발생했습니다: $error');
          },
        );
      }
    } catch (e) {
      print('🔴 Unexpected error: $e');
      
      // 안드로이드에서 다이얼로그 닫기 (Platform.isAndroid일 경우에만)
      if (Platform.isAndroid) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // 다이얼로그가 이미 닫혔을 수 있음
        }
      }
      
      onError('예기치 않은 오류: ${e.toString()}');
    }
  }

  static void _showAndroidNfcDialog(BuildContext context, VoidCallback onCancel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onCancel();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 제목
                const Text(
                  'Ready to Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // 설명 텍스트
                Text(
                  LocaleKeys.nfc_tag_nearby.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // 휴대폰 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF007AFF),
                      width: 4,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.smartphone,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                
                // 취소 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onCancel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
}
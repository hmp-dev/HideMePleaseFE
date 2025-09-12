import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/features/space/presentation/widgets/checkin_success_dialog.dart';
import 'package:stacked_services/stacked_services.dart';

/// 앱 레벨에서 오버레이를 관리하는 전역 서비스
class GlobalOverlayService {
  static OverlayEntry? _currentOverlay;
  static Timer? _autoCloseTimer;

  /// 체크인 성공 다이얼로그를 앱 레벨 오버레이로 표시
  static void showCheckInSuccessOverlay({
    required String spaceName,
    required String benefitDescription,
    required int availableBalance,
  }) {
    print('🌍 GlobalOverlayService: Showing CheckInSuccess overlay');
    print('   - spaceName: $spaceName');
    print('   - benefitDescription: $benefitDescription'); 
    print('   - availableBalance: $availableBalance');

    // 기존 오버레이가 있으면 제거
    _removeCurrentOverlay();

    try {
      // 앱의 최상위 Navigator 가져오기 (StackedService 사용)
      final context = StackedService.navigatorKey?.currentContext;
      
      if (context == null) {
        print('❌ GlobalOverlayService: Navigator context is null');
        return;
      }

      final overlay = Overlay.of(context);
      
      // OverlayEntry 생성
      _currentOverlay = OverlayEntry(
        builder: (context) => _buildOverlayContent(
          spaceName: spaceName,
          benefitDescription: benefitDescription,
          availableBalance: availableBalance,
        ),
      );

      // 오버레이 삽입
      overlay.insert(_currentOverlay!);
      print('✅ GlobalOverlayService: Overlay inserted successfully');

      // 5초 후 자동 닫기
      _autoCloseTimer = Timer(const Duration(seconds: 5), () {
        removeCheckInSuccessOverlay();
      });

    } catch (e) {
      print('❌ GlobalOverlayService: Failed to show overlay: $e');
    }
  }

  /// 오버레이 콘텐츠 빌드
  static Widget _buildOverlayContent({
    required String spaceName,
    required String benefitDescription,
    required int availableBalance,
  }) {
    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: () => removeCheckInSuccessOverlay(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // 다이얼로그 내부 터치는 무시
                  child: CheckinSuccessDialog(
                    spaceName: spaceName,
                    benefitDescription: benefitDescription,
                    availableBalance: availableBalance,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 체크인 성공 오버레이 제거
  static void removeCheckInSuccessOverlay() {
    print('🌍 GlobalOverlayService: Removing CheckInSuccess overlay');
    _removeCurrentOverlay();
  }

  /// 현재 오버레이 및 타이머 정리
  static void _removeCurrentOverlay() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// 모든 오버레이 정리 (앱 종료 시 호출)
  static void dispose() {
    _removeCurrentOverlay();
  }
}
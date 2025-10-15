import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CheckinSuccessDialog extends StatefulWidget {
  final String benefitDescription;
  final String spaceName;
  final int availableBalance;

  const CheckinSuccessDialog({
    super.key,
    required this.benefitDescription,
    required this.spaceName,
    required this.availableBalance,
  });

  @override
  State<CheckinSuccessDialog> createState() => _CheckinSuccessDialogState();
}

class _CheckinSuccessDialogState extends State<CheckinSuccessDialog> {
  Timer? _timer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    // 5초 후 자동으로 닫기 (안전한 방식으로)
    _timer = Timer(const Duration(seconds: 5), () {
      _safeCloseDialog();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 안전한 다이얼로그 닫기
  void _safeCloseDialog() {
    // 이미 닫는 중이면 중복 실행 방지
    if (_isClosing) return;
    
    // 위젯이 여전히 트리에 마운트되어 있는지 확인
    if (!mounted) return;
    
    _isClosing = true;
    
    try {
      // 현재 컨텍스트가 유효한지 확인
      final navigator = Navigator.of(context);
      
      // 다이얼로그 닫기 전에 백그라운드 화면 상태 확인
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isClosing) {
          _isClosing = true;
          navigator.pop();
        }
      });
      
      // 즉시 닫기
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      // 오류가 발생해도 로그만 남기고 앱이 크래시하지 않도록 함
      ('❌ Error closing CheckinSuccessDialog: $e').log();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _safeCloseDialog(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Background removed for light theme
              // Content Container
              Container(
                width: 370,
                margin: const EdgeInsets.only(top: 70),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF8FF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF132E41),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultImage(
                          path: "assets/icons/checkin_rewards_key.svg",
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          LocaleKeys.checkin_success_title.tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      LocaleKeys.checkin_success_congratulations.tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      LocaleKeys.checkin_success_reward.tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      LocaleKeys.checkin_success_matching_info.tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 2,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Labels Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.sav_earned.tr(),
                              style: const TextStyle(
                                color: Color(0xFFEA5211),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              LocaleKeys.sav_status.tr(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 10), // Space between columns
                        // Values Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ico_sav_red.svg',
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Color(0xFFEA5211),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ico_sav_gray.svg',
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.availableBalance.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Top Image
              Positioned(
                top: -150,
                child: DefaultImage(
                  path: "assets/icons/checkin_success_image.png",
                  width: 256,
                  height: 214,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

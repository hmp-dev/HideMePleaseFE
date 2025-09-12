import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class CheckinEmployDialog extends StatefulWidget {
  final String benefitDescription;
  final String spaceName;
  final VoidCallback onConfirm;

  const CheckinEmployDialog({
    super.key,
    required this.benefitDescription,
    required this.spaceName,
    required this.onConfirm,
  });

  @override
  State<CheckinEmployDialog> createState() => _CheckinEmployDialogState();
}

class _CheckinEmployDialogState extends State<CheckinEmployDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
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
                      const Text(
                        '체크인 혜택',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: 306,
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132E41).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.benefitDescription,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DefaultImage(
                              path: "assets/icons/checkin_space_title.svg",
                              width: 10,
                              height: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.spaceName,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '*각 제휴 공간에서 1일 1회 혜택을 사용할 수 있어.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '*직원이 아래 확인 버튼을 직접 누르도록 화면을 보여줘.',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing 
                            ? null 
                            : () {
                                Navigator.of(context).pop(false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isProcessing 
                              ? const Color(0x1A000000) 
                              : const Color(0x4D000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                            side: const BorderSide(
                              color: Color(0xFF132E41),
                              width: 1,
                            ),
                          ),
                          minimumSize: const Size(100, 38),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedOpacity(
                        opacity: _isProcessing ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _isProcessing 
                              ? null 
                              : () async {
                                  setState(() {
                                    _isProcessing = true;
                                  });
                                  
                                  // onConfirm 콜백 실행
                                  widget.onConfirm();
                                  
                                  // 다이얼로그 닫기
                                  if (mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                            minimumSize: const Size(179, 38),
                            shadowColor: Colors.transparent,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isProcessing 
                                        ? [const Color(0xFF2CB3FF).withOpacity(0.5), const Color(0xFF7CD0FF).withOpacity(0.5)]
                                        : [const Color(0xFF2CB3FF), const Color(0xFF7CD0FF)],
                                  ),
                                  borderRadius: BorderRadius.circular(19),
                                  border: Border.all(
                                    color: const Color(0xFF132E41),
                                    width: 1,
                                  ),
                                ),
                                child: Container(
                                  width: 179,
                                  height: 38,
                                  alignment: Alignment.center,
                                  child: _isProcessing 
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                          ),
                                        )
                                      : const Text(
                                          '사장님 확인',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -90,
              child: DefaultImage(
                path: "assets/icons/checkin_rewards_image.png",
                width: 134,
                height: 137,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class MatchingHelpDialog extends StatelessWidget {
  const MatchingHelpDialog({super.key});

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
              height: 242, // Adjusted height for the new title
              margin: const EdgeInsets.only(top: 0), // Make space for the image
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF23B0FF),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_matching_head.svg",
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '매칭이란?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '블루체크 매장에 방문하면 혜택을 받기 위해 [체크인]을 해',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '그리고 체크인 후 매장에 머무르는 걸 [하이딩]이라고 해',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '하이딩 시작 후 자동으로 [매칭]에 참여하게 되는데',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '매칭은 정해진 인원이 모이면 추가 리워드(SAV)를 주는 걸 말해!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultImage(
                        path: "assets/icons/icon_cautaion.svg",
                        width: 15,
                        height: 15,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '매장에서 50미터 벗어나면 하이딩과 매칭이 종료되니 주의해줘!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.zero, // Remove padding to make the container fit
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                      minimumSize: const Size(179, 38),
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2CB3FF), Color(0xFF7CD0FF)],
                        ),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Container(
                        width: 179,
                        height: 38,
                        alignment: Alignment.center,
                        child: const Text(
                          '확인했어!',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -230,
              child: DefaultImage(
                path: "assets/icons/matching_image.png",
                width: 218,
                height: 211,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

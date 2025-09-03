import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class CheckinSuccessDialog extends StatelessWidget {
  final String benefitDescription;
  final String spaceName;

  const CheckinSuccessDialog({
    super.key,
    required this.benefitDescription,
    required this.spaceName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
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
                        const Text(
                          '체크인 성공!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '블루체크 매장에 체크인하고 혜택받은 걸 축하해!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '보상으로 1 Savory를 증정할게!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '이제 자동으로 매칭에 참여하게 됐어 :)',
                      style: TextStyle(
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
                              'SAV 획듍',
                              style: TextStyle(
                                color: Color(0xFFEA5211),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'SAV 현황',
                              style: TextStyle(
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
                                  '1',
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
                                const Text(
                                  '132',
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

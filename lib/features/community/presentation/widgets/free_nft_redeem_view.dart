import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';

class FreeNftRedeemView extends StatelessWidget {
  final String totalNfts;
  final String redeemedNfts;
  final String remainingNfts;
  final VoidCallback onTap;

  const FreeNftRedeemView({
    super.key,
    required this.totalNfts,
    required this.redeemedNfts,
    required this.remainingNfts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CustomImageView(
              svgPath: 'assets/icons/title.svg',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '즉시 가입 가능한 커뮤니티',
                style: fontCompactMdMedium(),
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 16.0, bottom: 32.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: black100),
            image: const DecorationImage(
              image: AssetImage("assets/images/home_card_img.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: black100),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageView(
                    svgPath: 'assets/chain-logos/klaytn_chain.svg',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    "Ready to hide",
                    style: fontTitle01Bold(),
                  ),
                  const SizedBox(height: 46.0),
                  Center(
                    child: Lottie.asset('assets/lottie/lock.json',
                        width: 120, height: 120, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 64.0),
                  Row(
                    children: [
                      Text(
                        'NFT 수량',
                        style: fontTitle07(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  redeemedNfts,
                                  style: fontCompactLgBold(),
                                ),
                                Text(
                                  ' / ',
                                  style: fontBodyLg(),
                                ),
                                Text(
                                  totalNfts,
                                  style: fontBodyLg(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              remainingNfts,
                              style: fontBodyXs(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  HMPCustomButton(
                    bgColor: backgroundGr1,
                    text: 'Klip 연결하고 무료 NFT 받기',
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

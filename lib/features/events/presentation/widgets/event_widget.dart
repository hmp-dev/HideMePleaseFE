import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class EventWidget extends StatelessWidget {
  const EventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: bgNega5,
          height: 8.0,
          width: double.infinity,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
          color: bg1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이벤트 히스토리', style: fontTitle06Medium()),
              const SizedBox(height: 16.0),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  image: DecorationImage(
                    image: AssetImage("assets/images/event-bg-1.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("03/09(토) 13:00", style: fontCompactXs()),
                        const SizedBox(height: 10),
                        Text("Web3 Wednesday with WEMIX",
                            style: fontTitle04Bold()),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CustomImageView(
                              width: 20,
                              height: 20,
                              svgPath: "assets/icons/ic_space_disabled.svg",
                            ),
                            Text("하이드미 플리즈 을지로",
                                style: fontCompactSm(color: fore2)),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: DefaultButton(
                                      height: 36,
                                      onTap: () {},
                                      title: "신청 가능",
                                      color: bg1,
                                      textColor: hmpBlue,
                                      borderRadius: 4,
                                      textStyle: fontCompactSm(color: hmpBlue),
                                      iconWidget: Container(
                                        height: 4,
                                        width: 4,
                                        decoration: const BoxDecoration(
                                          color: hmpBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const HorizontalSpace(5),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CustomImageView(
                                          width: 20,
                                          height: 20,
                                          imagePath: "assets/images/img1.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-5, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CustomImageView(
                                            width: 20,
                                            height: 20,
                                            imagePath: "assets/images/img2.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-10, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CustomImageView(
                                            width: 20,
                                            height: 20,
                                            imagePath: "assets/images/img3.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "53명 모집됨",
                                    style: fontCompactSm(),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                CustomImageView(
                                  width: 40,
                                  height: 40,
                                  radius: BorderRadius.circular(4.0),
                                  imagePath: "assets/images/img3.png",
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 3.0,
                                  top: 3.0,
                                  child: DefaultImage(
                                    path:
                                        "assets/chain-logos/ethereum_chain.svg",
                                    height: 14,
                                    width: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < 2; i++)
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/event-bg-2.png")),
                  ),
                  foregroundDecoration: const BoxDecoration(
                    color: Colors.grey,
                    backgroundBlendMode: BlendMode.saturation,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('03/09(토) 13:00',
                            maxLines: 1, style: fontCompactXs()),
                        const SizedBox(height: 4.0),
                        Text('Web3 Wednesday with WEMIX',
                            maxLines: 2, style: fontTitle04Bold()),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            DefaultImage(
                              path: 'assets/icons/location.svg',
                              width: 16.0,
                              height: 16.0,
                            ),
                            const SizedBox(width: 2.0),
                            Text('하이드미 플리즈 을지로',
                                maxLines: 1,
                                style: fontCompactSm(color: fore2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          color: bgNega5,
          height: 8.0,
          width: double.infinity,
        ),
      ],
    );
  }
}

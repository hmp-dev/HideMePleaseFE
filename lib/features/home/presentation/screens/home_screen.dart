import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          DefaultImage(
            path: "assets/images/hide-me-please-logo.png",
            width: 200,
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "지갑을 연결하고\n웹컴 NFT를 받아보세요!",
              textAlign: TextAlign.center,
              style: fontR(18, lineHeight: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          RoundedButtonSmall(
            title: "지갑연결하기",
            onTap: () {},
          ),
          const SizedBox(height: 50),
          NFTCardWidgetParent(
            imagePath: "assets/images/home_card_img.png",
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultImage(
                    path: "assets/icons/chainIcon_x2.svg",
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ready To Hide",
                    style: fontB(32),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NFTCardWidgetParent extends StatelessWidget {
  const NFTCardWidgetParent(
      {super.key, required this.imagePath, required this.child});

  final String imagePath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              DefaultImage(
                path: imagePath,
                width: 326,
                height: 486,
              ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.dstATop,
                ),
                child: Container(
                  width: 326,
                  height: 486,
                  color: Colors.white,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 322,
                  height: 482,
                  color: bg1,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        DefaultImage(
                          path: imagePath,
                          width: 318,
                          height: 478,
                        ),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.5),
                            BlendMode.dstATop,
                          ),
                          child: Container(
                            width: 318,
                            height: 478,
                            color: Colors.white,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: DefaultImage(
                            path: imagePath,
                            width: 316,
                            height: 476,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

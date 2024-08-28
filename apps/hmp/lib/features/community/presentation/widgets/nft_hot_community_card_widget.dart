import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

class NftHotCommunityCardWidget extends StatelessWidget {
  const NftHotCommunityCardWidget(
      {super.key,
      required this.onTap,
      required this.title,
      required this.imagePath,
      required this.networkLogo,
      required this.timeAgo,
      required this.rank,
      required this.people});

  final VoidCallback onTap;
  final String title;
  final String imagePath;
  final String networkLogo;
  final String timeAgo;
  final String rank;
  final String people;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width * 0.40,
      height: 250,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imagePath.isEmpty)
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                width: 60,
                height: 60,
                fit: BoxFit.fitHeight,
                svgPath: "assets/images/hmp_eyes_up.svg",
              )
            else
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                url: imagePath,
                width: screenSize.width * 0.40,
                height: 250,
                fit: BoxFit.fitHeight,
              ),
            Container(
              width: screenSize.width * 0.40,
              height: 250,
              decoration: BoxDecoration(
                color: bg3.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            SizedBox(
              width: screenSize.width * 0.40,
              height: 250,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    getChainIcon(networkLogo),
                    const SizedBox(height: 8.0),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontB(18, lineHeight: 1.4),
                    ),
                    const Spacer(),
                    Center(
                      child: MembersCountValueRoundedWidget(
                        title: people, // "120명"
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomImageView getChainIcon(String chainPath) {
    if (chainPath.contains("klaytn")) {
      return CustomImageView(
        imagePath: chainPath,
        height: 24.0,
        width: 24.0,
      );
    }
    return CustomImageView(
      svgPath: chainPath,
      height: 24.0,
      width: 24.0,
    );
  }
}

class MembersCountValueRoundedWidget extends StatelessWidget {
  const MembersCountValueRoundedWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          decoration: BoxDecoration(
            color: black900.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.only(left: 5, top: 5, right: 10, bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: DefaultImage(
                  path: "assets/icons/ic_triangle_arrow_up.svg",
                  width: 14,
                  height: 14,
                  color: pink,
                  boxFit: BoxFit.fitHeight,
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: fontR(14, lineHeight: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/nft_video_thumbnail.dart';

class SelectedNftItem extends StatelessWidget {
  const SelectedNftItem({
    super.key,
    required this.index,
    required this.imageUrl,
    required this.videoUrl,
    required this.name,
    required this.chain,
  });

  final int index;
  final String imageUrl;
  final String name;
  final String chain;
  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                videoUrl != ""
                    ? NftVideoThumbnailFromUrl(
                        imageWidth: 63,
                        imgHeight: 64,
                        videoUrl: videoUrl,
                      )
                    : imageUrl != ""
                        ? CustomImageView(
                            url: imageUrl,
                            width: 63,
                            height: 64,
                          )
                        : DefaultImage(
                            path: "assets/images/place_holder_card.png",
                            width: 63,
                            height: 64,
                            boxFit: BoxFit.cover,
                          ),
                const HorizontalSpace(20),
                SizedBox(
                  width: 100,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: fontBodyMdBold(),
                  ),
                )
              ],
            ),
            ReorderableDragStartListener(
              index: index,
              child: Container(
                height: 64.0,
                width: 64.0,
                alignment: Alignment.centerRight,
                child: DefaultImage(
                  path: "assets/icons/ic_drag_bars.svg",
                  color: fore1,
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(),
        ),
      ],
    );
  }
}

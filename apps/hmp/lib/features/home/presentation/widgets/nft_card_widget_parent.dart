import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/nft_video_thumbnail.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class NFTCardWidgetParent extends StatefulWidget {
  const NFTCardWidgetParent({
    super.key,
    required this.imagePath,
    required this.topWidget,
    required this.bottomWidget,
    required this.index,
    required this.videoUrl,
  });

  final String imagePath;
  final String videoUrl;
  final Widget topWidget;
  final Widget bottomWidget;
  final int index;

  @override
  State<NFTCardWidgetParent> createState() => _NFTCardWidgetParentState();
}

class _NFTCardWidgetParentState extends State<NFTCardWidgetParent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Stack(
          children: [
            const VerticalSpace(20),
            Container(
              width: 326,
              height: 486,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: fore4),
              ),
              child: widget.videoUrl.isNotEmpty
                  ? SizedBox(
                      width: 326,
                      height: 486,
                      child: NftVideoThumbnailFromUrl(
                        imgHeight: 486,
                        imageWidth: 326,
                        videoUrl: widget.videoUrl,
                      ),
                    )
                  : widget.imagePath == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 326,
                          height: 486,
                          border: Border.all(
                            color: fore4,
                            width: 1,
                          ),
                        )
                      : CustomImageView(
                          url: widget.imagePath,
                          width: 326,
                          height: 486,
                          border: Border.all(color: fore4, width: 1),
                          fit: BoxFit.fitHeight,
                        ),
            ),
            _buildBlackGradientOverlayTop(),
            _buildBlackGradientOverlayBottom(),
            Container(
              width: 326,
              height: 486,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  width: 324,
                  height: 484,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: black, width: 2),
                  ),
                  child: Container(
                    width: 322,
                    height: 482,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: black100,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 486,
              width: 326,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.topWidget,
                  const Spacer(),
                  widget.bottomWidget,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  //  ===
  Widget _buildBlackGradientOverlayTop() {
    return Positioned.fill(
      top: 0,
      child: Container(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.00),
            colors: [Colors.black, black100.withOpacity(0.001)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBlackGradientOverlayBottom() {
    return Positioned.fill(
      bottom: 0,
      child: Container(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.00, 1.00),
            end: const Alignment(0, -0.001),
            colors: [Colors.black, black100.withOpacity(0.001)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: black100, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

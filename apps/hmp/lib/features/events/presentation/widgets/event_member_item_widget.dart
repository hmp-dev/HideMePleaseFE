import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/events/presentation/views/event_detail_view.dart';

class EventMemberItemWidget extends StatelessWidget {
  const EventMemberItemWidget({
    super.key,
    required this.memberTempDto,
    this.isLastItem = false,
    this.onTap,
  });

  final EventMemberTempDto memberTempDto;
  final bool isLastItem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  memberTempDto.pfpImage == ""
                      ? CustomImageView(
                          imagePath: "assets/images/place_holder_card.png",
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(100),
                          fit: BoxFit.cover,
                        )
                      : CustomImageView(
                          imagePath: memberTempDto.pfpImage,
                          width: 36,
                          height: 36,
                          radius: BorderRadius.circular(100),
                          fit: BoxFit.cover,
                        ),
                ],
              ),
              const HorizontalSpace(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memberTempDto.name, style: fontCompactLgBold()),
                  const VerticalSpace(5),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: DefaultImage(
                  path: "assets/icons/ic_angle_arrow_right.svg",
                  width: 24,
                  height: 24,
                  color: fore3,
                ),
              ),
            ],
          ),
          isLastItem
              ? const SizedBox(height: 20)
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: fore5),
                )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';

class EventsWidget extends StatefulWidget {
  const EventsWidget({super.key});

  @override
  State<EventsWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends State<EventsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("참여 이벤트", style: fontTitle06Medium()),
            const HorizontalSpace(10),
            Text("4", style: fontTitle07()),
          ],
        ),
        const SizedBox(height: 20),
        const EventItemWidget(
          bgImage: "assets/images/event-bg-1.png",
        ),
        const SizedBox(height: 20),
        const EventItemWidget(
          bgImage: "assets/images/event-bg-2.png",
        )
      ],
    );
  }
}

class EventItemWidget extends StatelessWidget {
  const EventItemWidget({
    super.key,
    required this.bgImage,
  });

  final String bgImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      width: MediaQuery.of(context).size.width - 40,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("03/09(토) 13:00", style: fontCompactXs()),
              const SizedBox(height: 10),
              Text("Web3 Wednesday with WEMIX", style: fontTitle04Bold()),
              const SizedBox(height: 10),
              Row(
                children: [
                  CustomImageView(
                    width: 20,
                    height: 20,
                    svgPath: "assets/icons/ic_space_disabled.svg",
                  ),
                  Text("하이드미 플리즈 을지로", style: fontCompactSm(color: fore2)),
                ],
              ),
              const SizedBox(height: 10),
              const Spacer(),
              Row(
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
                        borderRadius: BorderRadius.circular(100),
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
                          borderRadius: BorderRadius.circular(100),
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
                          borderRadius: BorderRadius.circular(100),
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

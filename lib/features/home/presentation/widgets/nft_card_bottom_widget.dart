import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/glassmorphic_button.dart';

class NftCardBottomWidget extends StatelessWidget {
  const NftCardBottomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "선착순 홀더",
                style: fontR(16),
              ),
              Row(
                children: [
                  Text(
                    "1,308",
                    style: fontSB(18),
                  ),
                  Text('/2,000', style: fontR(18))
                ],
              )
            ],
          ),
          const VerticalSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Floor Price",
                style: fontSB(18),
              ),
              Text(
                "무료",
                style: fontSB(18),
              )
            ],
          ),
          const VerticalSpace(10),
          GlassmorphicButton(
            width: MediaQuery.of(context).size.width * 0.80,
            height: 60,
            onPressed: () {},
            child: Text(
              '자세히 보기',
              style: fontM(16),
            ),
          )
        ],
      ),
    );
  }
}

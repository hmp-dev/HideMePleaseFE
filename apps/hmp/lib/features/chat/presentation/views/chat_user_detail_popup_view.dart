import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:sendbird_uikit/sendbird_uikit.dart';
import 'package:sendbird_uikit/src/internal/component/basic/sbu_text_component.dart';
import 'package:sendbird_uikit/src/internal/resource/sbu_text_styles.dart';

class ChatUserDetailPopupView extends StatefulWidget {
  final String userId;
  final String userNickname;
  final String userProfileImg;
  final String userDescription;
  final VoidCallback onUserDetailsTapped;

  const ChatUserDetailPopupView({
    super.key,
    required this.userId,
    required this.userNickname,
    required this.userProfileImg,
    required this.userDescription,
    required this.onUserDetailsTapped,
  });

  @override
  State<StatefulWidget> createState() => ChatUserDetailPopupViewState();
}

class ChatUserDetailPopupViewState extends State<ChatUserDetailPopupView> {
  @override
  Widget build(BuildContext context) {
    bool isLightTheme = false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isLightTheme ? SBUColors.background50 : SBUColors.background500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: CustomImageView(
              url: widget.userProfileImg,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              radius: BorderRadius.circular(34),
              placeHolder: "assets/images/launcher-icon.png",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SBUTextComponent(
              text: widget.userNickname,
              textType: SBUTextType.heading1,
              textColorType: SBUTextColorType.text01,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
            child: Container(
              height: 1,
              color: SBUColors.lightThemeTextDisabled,
            ),
          ),
          InkWell(
            onTap: widget.onUserDetailsTapped,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: fore4),
              ),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text('자세히 보기', style: fontCompactMdMedium()),
            ),
          ),
          // SizedBox(
          //   width: double.maxFinite,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
          //     child: SBUTextComponent(
          //       text: strings.userId,
          //       textType: SBUTextType.body2,
          //       textColorType: SBUTextColorType.text02,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 4, right: 16, bottom: 24),
              child: SBUTextComponent(
                text: widget.userDescription,
                textType: SBUTextType.body3,
                textColorType: SBUTextColorType.text01,
              ),
            ),
          ),
          const SizedBox(height: 38.0),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/community/presentation/cubit/dummy_data.dart';

class ParticipatedCommunityNftView extends StatelessWidget {
  final String communityPeoples;
  final List<ChatMessage> recentMsgs;
  final String communityName;
  final String networkLogo;
  final int unreadMsgCount;
  final VoidCallback onTap;

  const ParticipatedCommunityNftView({
    super.key,
    required this.communityPeoples,
    required this.recentMsgs,
    required this.communityName,
    required this.networkLogo,
    required this.unreadMsgCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0, bottom: 32.0),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: black100),
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
              svgPath: networkLogo,
              width: 28,
              height: 28,
            ),
            const SizedBox(height: 16.0),
            Text(
              communityName,
              maxLines: 2,
              style: fontTitle01Bold(),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Text(
                communityPeoples,
                style: fontCompactSm(),
              ),
            ),
            const Spacer(),
            Column(
              children: recentMsgs
                  .map((msg) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Text(
                              msg.senderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontCompactSmMedium(),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                                child: Text(
                              msg.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontCompactSm(color: fore2),
                            )),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8.0),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 11.5),
                side: const BorderSide(color: fore4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('채팅방 입장', style: fontCompactMdMedium()),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: hmpBlue,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      unreadMsgCount.toString(),
                      style: fontCompact2XsBold(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

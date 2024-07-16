import 'package:flutter/material.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/chat/presentation/views/chat_user_detail_popup_view.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/my/presentation/cubit/member_details_cubit.dart';
import 'package:mobile/features/my/presentation/screens/member_details_screen.dart';

class ChatUserDetailPopupScreen extends StatelessWidget {
  final String userId;
  final String userNickname;
  final String userProfileImg;

  const ChatUserDetailPopupScreen({
    super.key,
    required this.userId,
    required this.userNickname,
    required this.userProfileImg,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberDetailsCubit, MemberDetailsState>(
      bloc: getIt<MemberDetailsCubit>()..onStart(userId: userId),
      builder: (context, detailsState) {
        return ChatUserDetailPopupView(
          userId: userId,
          userNickname: userNickname,
          userProfileImg: detailsState.profile.pfpImageUrl.isNotEmpty
              ? detailsState.profile.pfpImageUrl
              : userProfileImg,
          userDescription: detailsState.profile.introduction,
          onUserDetailsTapped: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberDetailsScreen(
                    member: const CommunityMemberEntity.empty()
                        .copyWith(userId: userId)),
              ),
            );
          },
        );
      },
    );
  }
}

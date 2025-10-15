import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/friends/domain/entities/friend_request_entity.dart';
import 'package:mobile/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_dialog.dart';
import 'package:mobile/features/friends/presentation/widgets/friend_request_success_dialog.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class FriendRequestListDialog extends StatefulWidget {
  const FriendRequestListDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return const FriendRequestListDialog();
      },
    );
  }

  @override
  State<FriendRequestListDialog> createState() => _FriendRequestListDialogState();
}

class _FriendRequestListDialogState extends State<FriendRequestListDialog> {
  @override
  void initState() {
    super.initState();
    // 받은 친구 신청 목록 로드
    getIt<FriendsCubit>().getReceivedFriendRequests();
  }

  Future<void> _handleAcceptRequest(FriendRequestEntity request) async {
    // 세이보리 잔액 확인 (친구 수락에 5 SAV 필요)
    final profileCubit = getIt<ProfileCubit>();
    final currentBalance = profileCubit.state.userProfileEntity.availableBalance;

    if (currentBalance < 5) {
      // 잔액 부족 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF000000), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.insufficient_savory_balance.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff00A3FF), Color(0xff5FC5FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF000000), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        LocaleKeys.confirm.tr(),
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    // 수락 확인 다이얼로그 표시 (수락 모드)
    final confirmed = await FriendRequestDialog.show(
      context,
      nickName: request.requester.nickName,
      profileImageUrl: request.requester.profileImageUrl ?? '',
      introduction: request.requester.introduction ?? '',
      isAcceptMode: true, // 수락 모드
    );

    if (confirmed == true) {
      // 친구 신청 수락
      await getIt<FriendsCubit>().acceptFriendRequest(request.id);

      // 성공 다이얼로그 표시
      if (mounted) {
        // 현재 사용자의 프로필을 다시 로드하여 최신 포인트 가져오기
        final profileCubit = getIt<ProfileCubit>();
        await profileCubit.init();

        await FriendRequestSuccessDialog.show(
          context,
          savoryBalance: profileCubit.state.userProfileEntity.availableBalance,
          isAcceptMode: true, // 수락 모드
        );

        // 목록 새로고침
        getIt<FriendsCubit>().getReceivedFriendRequests();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.9;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF8FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF000000), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 및 닫기 버튼
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/ico_noti_friend.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        LocaleKeys.friend_request.tr(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 안내 메시지
            Text(
              LocaleKeys.friend_request_list_info.tr(),
              style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 친구 신청 목록
            Flexible(
              child: BlocBuilder<FriendsCubit, FriendsState>(
                bloc: getIt<FriendsCubit>(),
                builder: (context, state) {
                  if (state.submitStatus == RequestStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.receivedRequests.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.no_friend_requests.tr(),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.receivedRequests.length,
                    itemBuilder: (context, index) {
                      final request = state.receivedRequests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF132E41).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // 프로필 이미지
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF132E41),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: (request.requester.profileImageUrl?.isNotEmpty ?? false)
                                        ? Image.network(
                                            request.requester.profileImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/profile_img.png',
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/profile_img.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // 닉네임 및 소개
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.requester.nickName,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (request.requester.introduction?.isNotEmpty ?? false) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          request.requester.introduction!,
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 프렌즈 신청 수락 버튼
                            GestureDetector(
                              onTap: () => _handleAcceptRequest(request),
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff00A3FF),
                                      Color(0xff5FC5FF),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF000000),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    LocaleKeys.accept_friend_request.tr(),
                                    style: const TextStyle(
                                      color: Color(0xFF000000),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

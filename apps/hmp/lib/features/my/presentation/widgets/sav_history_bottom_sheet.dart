import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/domain/entities/point_transaction_entity.dart';

class SavHistoryBottomSheet extends StatefulWidget {
  final int balance;

  const SavHistoryBottomSheet({
    super.key,
    required this.balance,
  });

  static Future<void> show(BuildContext context, int balance) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavHistoryBottomSheet(balance: balance),
    );
  }

  @override
  State<SavHistoryBottomSheet> createState() => _SavHistoryBottomSheetState();
}

class _SavHistoryBottomSheetState extends State<SavHistoryBottomSheet> {
  final Set<int> _expandedIndices = {};
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    // 바텀시트가 열릴 때 포인트 히스토리 조회
    _profileCubit.getPointsHistory();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(
          color: const Color(0xFF132E41),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 드래그 인디케이터
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF132E41).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // 타이틀 섹션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/ico_noti_sav.png',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Savory',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 스크롤 가능 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // 잔액 표시 (중앙 정렬)
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/ico_bigsav.png',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.balance}',
                          style: const TextStyle(
                            color: Color(0xFFEA5211),
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 설명 박스
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF132E41),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 아이콘 (크기 증가)
                        Image.asset(
                          'assets/icons/checkin_success_image.png',
                          width: 64,
                          height: 64,
                        ),
                        const SizedBox(width: 10),
                        // 텍스트
                        const Expanded(
                          child: Text(
                            '세이보리는 하미플 세계에서 쓰는 소셜 화폐야.\\n친구도 만들고, 내가 숨은 곳도 알리고,\\n사이렌까지 울릴 수 있어!',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 거래 내역 리스트
                  BlocBuilder<ProfileCubit, ProfileState>(
                    bloc: _profileCubit,
                    builder: (context, state) {
                      if (state.pointsHistoryStatus == RequestStatus.loading) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF132E41),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF19BAFF),
                            ),
                          ),
                        );
                      }

                      if (state.pointsHistoryStatus == RequestStatus.failure) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF132E41),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '거래 내역을 불러올 수 없습니다',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      final transactions = state.pointsHistory;

                      if (transactions.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF132E41),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '거래 내역이 없습니다',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF132E41),
                            width: 1,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: const Color(0xFF132E41).withValues(alpha: 0.1),
                            indent: 20,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final isExpanded = _expandedIndices.contains(index);
                            final isEarn = transaction.type == PointTransactionType.EARNED;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedIndices.remove(index);
                                  } else {
                                    _expandedIndices.add(index);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 아이콘 (획득/사용) - 상단 정렬
                                        Image.asset(
                                          isEarn
                                              ? 'assets/icons/ico_plus.png'
                                              : 'assets/icons/ico_minus.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        // 제목
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                transaction.displayTitle,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                transaction.formattedDate,
                                                style: TextStyle(
                                                  color: Colors.black.withValues(alpha: 0.6),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 펼침 아이콘
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF132E41),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    // 펼쳤을 때 상세 설명
                                    if (isExpanded) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF8FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          transaction.description,
                                          style: TextStyle(
                                            color: Colors.black.withValues(alpha: 0.7),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

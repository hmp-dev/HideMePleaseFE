import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/my/presentation/cubit/member_details_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/membership_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/points_cubit.dart';
import 'package:mobile/features/my/presentation/views/member_details_view.dart';

class MemberDetailsScreen extends StatefulWidget {
  const MemberDetailsScreen({super.key, required this.member});

  final CommunityMemberEntity member;

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  @override
  void dispose() {
    getIt.resetLazySingleton<MembershipCubit>();
    getIt.resetLazySingleton<PointsCubit>();
    getIt.resetLazySingleton<MemberDetailsCubit>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberDetailsCubit, MemberDetailsState>(
      bloc: getIt<MemberDetailsCubit>()..onStart(userId: widget.member.userId),
      builder: (context, detailsState) {
        return BlocBuilder<MembershipCubit, MembershipState>(
          bloc: getIt<MembershipCubit>()..onStart(userId: widget.member.userId),
          builder: (context, membershipsState) {
            return BlocBuilder<PointsCubit, PointsState>(
              bloc: getIt<PointsCubit>()..onStart(userId: widget.member.userId),
              builder: (context, pointsState) {
                return MemberDetailsView(
                  user: detailsState.profile,
                  selectedNftTokensList: membershipsState.selectedNftTokensList,
                  nftPointsList: pointsState.nftPointsList,
                  isMembersLoading: membershipsState.isLoading,
                  isPointsLoading: pointsState.isLoading,
                );
              },
            );
          },
        );
      },
    );
  }
}

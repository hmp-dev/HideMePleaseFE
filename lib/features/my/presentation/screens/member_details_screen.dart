import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/my/presentation/cubit/membership_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/points_cubit.dart';
import 'package:mobile/features/my/presentation/views/member_details_view.dart';

class MemberDetailsScreen extends StatelessWidget {
  const MemberDetailsScreen({super.key, required this.member});

  final CommunityMemberEntity member;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MembershipCubit, MembershipState>(
      bloc: getIt<MembershipCubit>()..onStart(userId: member.userId),
      builder: (context, membershipsState) {
        return BlocBuilder<PointsCubit, PointsState>(
          bloc: getIt<PointsCubit>()..onStart(userId: member.userId),
          builder: (context, pointsState) {
            return MemberDetailsView(
              member: member,
              selectedNftTokensList: membershipsState.selectedNftTokensList,
              nftPointsList: pointsState.nftPointsList,
            );
          },
        );
      },
    );
  }
}

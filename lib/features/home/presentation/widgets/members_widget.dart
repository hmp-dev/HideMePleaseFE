import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/community/presentation/cubit/community_details_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/home/presentation/widgets/home_member_item_widget.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MemberWidget extends StatefulWidget {
  const MemberWidget({super.key});

  @override
  State<MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityDetailsCubit, CommunityDetailsState>(
      bloc: getIt<CommunityDetailsCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalSpace(10),
            Text(LocaleKeys.pointRanking.tr(), style: fontTitle06Medium()),
            const VerticalSpace(20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.communityMembers.length,
              itemBuilder: (context, index) {
                return HomeMemberItemWidget(
                  communityMemberEntity: state.communityMembers[index],
                  isLastItem: index == state.communityMembers.length - 1,
                  onTap: () {},
                );
              },
            ),
            const VerticalSpace(20),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/common/presentation/cubit/enable_location_cubit.dart';
import 'package:mobile/features/community/presentation/cubit/community_cubit.dart';
import 'package:mobile/features/community/presentation/views/community_view.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    getIt<CommunityCubit>().onStart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      bloc: getIt<CommunityCubit>(),
      builder: (context, state) {
        return CommunityView(
          allNftCommunities: state.allNftCommunities,
          communityCount: state.communityCount,
          itemCount: state.itemCount,
          hotNftCommunities: state.hotNftCommunities,
          userNftCommunities: state.userNftCommunities,
          allNftCommOrderBy: state.allNftCommOrderBy,
        );
      },
    );
  }
}

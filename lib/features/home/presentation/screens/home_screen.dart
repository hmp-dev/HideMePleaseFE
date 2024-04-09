import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/home_view_type.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_with_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_after_login_without_nft.dart';
import 'package:mobile/features/home/presentation/views/home_view_before_login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      bloc: getIt<HomeCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: getHomeView(state.homeViewType),
        );
      },
    );
  }

  getHomeView(HomeViewType homeViewType) {
    if (homeViewType == HomeViewType.AfterLoginWithOutNFT) {
      return const HomeViewAfterLoginWithOutNFT();
    } else if (homeViewType == HomeViewType.AfterLoginWithNFT) {
      return const HomeViewAfterLoginWithNFT();
    } else {
      return const HomeViewBeforeLogin();
    }
  }
}

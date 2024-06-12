import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/linked_wallet_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/edit_my_screen.dart';
import 'package:mobile/features/my/presentation/widgets/my_membership_widget.dart';
import 'package:mobile/features/my/presentation/widgets/my_points_widget.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyScreen(),
      ),
    );
  }

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with TickerProviderStateMixin {
  late TabController tabViewController;

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: getIt<ProfileCubit>(),
      listener: (context, state) {},
      builder: (context, state) {
        final userData = state.userProfileEntity;
        return BaseScaffold(
          title: LocaleKeys.myPage.tr(),
          isCenterTitle: true,
          onBack: () {
            Navigator.pop(context);
          },
          suffix: GestureDetector(
            onTap: () {
              MyEditScreen.push(context, userData);
            },
            child: DefaultImage(
                path: "assets/icons/img_icon_system.svg",
                width: 32,
                height: 32),
          ),
          body: SafeArea(
            child: BlocListener<AppCubit, AppState>(
              bloc: getIt<AppCubit>(),
              listener: (context, appState) {
                if (!appState.isLoggedIn) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.startUpScreen,
                    (route) => false,
                  );
                }
              },
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTitleRow(context, userData),
                  const SizedBox(height: 24),
                  _buildTabView(context),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 1000,
                    child: TabBarView(
                      controller: tabViewController,
                      children: const [
                        MyMembershipWidget(),
                        MyPointsWidget(),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    UserProfileEntity userProfile,
  ) {
    final connectedWalletsList = getIt<WalletsCubit>().state.connectedWallets;
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: userProfile.pfpImageUrl.isNotEmpty
                ? CustomImageView(
                    url: userProfile.pfpImageUrl,
                    fit: BoxFit.cover,
                    width: 68,
                    height: 68,
                  )
                : CustomImageView(
                    imagePath: "assets/images/profile_img.png",
                    fit: BoxFit.cover,
                    width: 68,
                    height: 68,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile.nickName, //name I am a dreaming octopus
                    style: fontCompactLgBold(),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 226,
                    child: Text(
                      userProfile.introduction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontCompactSm(color: fore2),
                    ),
                  ),
                  const VerticalSpace(10),
                  LinkedWalletButton(
                    titleText: LocaleKeys.linkedWallet.tr(),
                    count: connectedWalletsList.length,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildTabView(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: deviceWidth,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: whiteWithOpacityOne,
                width: 0.7,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: TabBar(
            controller: tabViewController,
            isScrollable: true,
            labelColor: white,
            labelStyle: fontCompactMdBold(),
            unselectedLabelColor: white.withOpacity(0.5),
            dividerColor: Colors.transparent,
            unselectedLabelStyle: fontCompactMdBold(color: fore2),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: white,
            indicatorWeight: 1,
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: white, width: 0.5),
              ),
            ),
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(
                child: SizedBox(
                  width: deviceWidth * 0.45,
                  child: Center(
                    child: Text(
                      LocaleKeys.membership.tr(),
                    ),
                  ),
                ),
              ),
              Tab(
                child: SizedBox(
                  width: deviceWidth * 0.45,
                  child: Center(
                    child: Text(
                      LocaleKeys.points.tr(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/edit_my_screen.dart';
import 'package:mobile/features/my/presentation/widgets/my_page.dart';
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
              // Log.info("logout is tapped");
              // getIt<AppCubit>().onLogOut();

              MyEditScreen.push(context);
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
                  const SizedBox(height: 32),
                  _buildTabView(context),
                  SizedBox(
                    height: 496,
                    child: TabBarView(
                      controller: tabViewController,
                      children: const [
                        MyPage(),
                        MyPage(),
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
            child: DefaultImage(
              path: "assets/images/profile_img.png",
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
                    "나는꿈을꾸는문어", //name I am a dreaming octopus
                    style: fontM(16),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 226,
                    child: Text(
                      "높은 산에 올라가면 나는 초록색 문어, 장미 꽃밭 숨어들면 나는 빨간색 문어",
                      // introduction Text
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontR(14,
                          color: Colors.white.withOpacity(0.7),
                          lineHeight: 1.3),
                    ),
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
            labelStyle: fontM(16),
            unselectedLabelColor: white.withOpacity(0.5),
            dividerColor: Colors.transparent,
            unselectedLabelStyle: fontM(16),
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

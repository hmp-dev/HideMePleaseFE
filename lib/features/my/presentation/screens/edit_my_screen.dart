import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_field.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_toggle.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyEditScreen extends StatefulWidget {
  const MyEditScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyEditScreen(),
      ),
    );
  }

  @override
  State<MyEditScreen> createState() => _MyEditScreenState();
}

class _MyEditScreenState extends State<MyEditScreen>
    with TickerProviderStateMixin {
  late TabController tabViewController;

  String nickName = "";
  String introduction = "";

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.editMyPage.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      suffix: GestureDetector(
        onTap: () {
          Log.info("logout is tapped");
          getIt<AppCubit>().onLogOut();
        },
        child: const Icon(Icons.logout),
      ),
      body: SafeArea(
        child: BlocListener<AppCubit, AppState>(
          bloc: getIt<AppCubit>(),
          listener: (context, state) {
            if (!state.isLoggedIn) {
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.startUpScreen, (route) => false);
            }
          },
          child: SingleChildScrollView(
            child: BlocConsumer<ProfileCubit, ProfileState>(
              bloc: getIt<ProfileCubit>(),
              listener: (context, state) {},
              builder: (context, state) {
                final userProfile = state.userProfileEntity;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTitleRow(context, userProfile),
                      const SizedBox(height: 32),
                      Text(
                        LocaleKeys.nickName.tr(),
                        style: fontBodySmMedium(),
                      ),
                      const SizedBox(height: 8),
                      DefaultField(
                        initialValue: userProfile.nickName,
                        hintText: LocaleKeys.nickName.tr(),
                        isBorderType: true,
                        onChange: (text) {
                          setState(() {
                            nickName = text;
                          });
                        },
                        onEditingComplete: () {
                          Log.info("On editing Complete is called");
                          // unfocus and close the Soft Key Board
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (nickName.isNotEmpty) {
                            getIt<ProfileCubit>().onUpdateUserProfile(
                                UpdateProfileRequestDto(nickName: nickName));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocaleKeys.introduction.tr(),
                        style: fontBodySmMedium(),
                      ),
                      const SizedBox(height: 8),
                      DefaultField(
                        initialValue: userProfile.introduction,
                        hintText: LocaleKeys.introduction.tr(),
                        isBorderType: true,
                        onChange: (text) {
                          setState(() {
                            introduction = text;
                          });
                        },
                        onEditingComplete: () {
                          Log.info("On editing Complete is called");
                          // unfocus and close the Soft Key Board
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (introduction.isNotEmpty) {
                            getIt<ProfileCubit>().onUpdateUserProfile(
                                UpdateProfileRequestDto(
                                    introduction: introduction));
                          }
                        },
                      ),
                      const VerticalSpace(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const VisitStatusText(),
                          Row(
                            children: [
                              userProfile.locationPublic
                                  ? Text(
                                      LocaleKeys.iWillRevealIt.tr(),
                                      style: fontCompactSm(),
                                    )
                                  : Text(
                                      LocaleKeys.iWillHideIt.tr(),
                                      style: fontCompactSm(),
                                    ),
                              const HorizontalSpace(5),
                              CustomToggle(
                                initialValue: userProfile.locationPublic,
                                onTap: (bool value) {
                                  getIt<ProfileCubit>().onUpdateUserProfile(
                                      UpdateProfileRequestDto(
                                          locationPublic: value));
                                },
                                toggleColor: Colors.black,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: bgNega5),
                      ),
                      GestureDetector(
                        onTap: () {
                          getIt<NftCubit>().onGetNftCollections();
                          MyMembershipSettingsScreen.push(context);
                        },
                        child: Center(
                          child: Text(
                            LocaleKeys.editMembershipList.tr(),
                            style: fontCompactMd(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, UserProfileEntity userProfile) {
    return Center(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: DefaultImage(
              path: "assets/images/profile_img.png",
              width: 88,
              height: 88,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: hmpBlue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: DefaultImage(
                    path: "assets/icons/img_icon_system.svg",
                    width: 16,
                    height: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
}

class VisitStatusText extends StatelessWidget {
  const VisitStatusText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          LocaleKeys.visitStatusDisclosure.tr(),
          style: fontCompactMd(),
        ),
        const HorizontalSpace(5),
        DefaultImage(
          path: "assets/icons/ic_Info_bold.svg",
          width: 20,
          height: 20,
          color: white,
        )
      ],
    );
  }
}

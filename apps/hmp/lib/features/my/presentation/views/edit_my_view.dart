import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/values.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/app/presentation/cubit/app_cubit.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_field.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/default_toggle.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/info_text_tool_tip_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/my/presentation/cubit/nick_name_cubit.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/my/presentation/screens/select_profile_image_screen.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// `MyEditView` is a stateful widget that displays the user's editable data.
///
/// It requires a [UserProfileEntity] `userData` to display the user's
/// profile image, nickname, and introduction. It also requires a [NickNameState]
/// `nickNameState` to display the nickname availability and error message.
/// The widget is stateful because it needs to keep track of the user's input
/// and the scroll position of the form.
class MyEditView extends StatefulWidget {
  const MyEditView({
    super.key,
    required this.userData,
    required this.nickNameState,
  });

  /// The user's profile data.
  final UserProfileEntity userData;

  /// The nickname state of the user.
  final NickNameState nickNameState;

  @override
  State<MyEditView> createState() => _MyEditViewState();
}

class _MyEditViewState extends State<MyEditView> {
  // ScrollController for the ScrollView.
  //
  // Used to control the scroll position of the form.
  late ScrollController _scrollController;

  // The user's nickname.
  //
  // Used to keep track of the user's input in the nickname field.
  String nickName = "";

  // The user's introduction.
  //
  // Used to keep track of the user's input in the introduction field.
  String introduction = "";

  // Indicates whether or not to show the tooltip.
  //
  // Used to control the visibility of the tooltip widget based on whether
  // or not the user has scrolled past the nickname field.
  bool _isShowToolTip = false;

  // Indicates whether or not the user's location is public.
  //
  // Used to keep track of the user's location setting and to display the
  // toggle button accordingly.
  bool isLocationPublic = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    setIsLocationPublic();
  }

  setIsLocationPublic() {
    isLocationPublic = widget.userData.locationPublic;
  }

  @override
  void dispose() {
    getIt.resetLazySingleton<NickNameCubit>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AppCubit, AppState>(
        bloc: getIt<AppCubit>(),
        listener: (context, state) {
          if (!state.isLoggedIn) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.startUpScreen, (route) => false);
          }
        },
        child: BlocConsumer<ProfileCubit, ProfileState>(
          bloc: getIt<ProfileCubit>(),
          listener: (context, state) {
            if (state.isSubmitSuccess) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final userProfile = state.userProfileEntity;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileImageWidget(context, userProfile),
                            const SizedBox(height: 32),
                            buildInputLabelText(LocaleKeys.nickName.tr()),
                            const SizedBox(height: 8),
                            DefaultField(
                              onFocus: (isFocused) {
                                "isFocused: value is $isFocused".log();
                                if (isFocused) {
                                  _scrollController.animateTo(
                                    _scrollController.position.minScrollExtent,
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeIn,
                                  );
                                }
                              },
                              initialValue: userProfile.nickName,
                              hintText: LocaleKeys.pleaseEnterYourName.tr(),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣/ㄴㄴㄴ]"))
                              ],
                              isBorderType: true,
                              guideMsg: widget.nickNameState.nickName == ''
                                  ? ''
                                  : widget.nickNameState.nickNameError
                                      ? LocaleKeys.nickNameIsAlreadyUsed.tr()
                                      : LocaleKeys.available.tr(),
                              isError: widget.nickNameState.nickNameError,
                              color: widget.nickNameState.nickNameError
                                  ? null
                                  : blue,
                              onChange: (text) {
                                setState(() {
                                  nickName = text;
                                });
                                if (text.length > 3 &&
                                    text != userProfile.nickName) {
                                  getIt<NickNameCubit>()
                                      .onCheckNickName(nickName: text);
                                }
                              },
                              onEditingComplete: () {
                                // unfocus and close the Soft Key Board
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                return;
                              },
                            ),
                            const SizedBox(height: 16),
                            buildInputLabelText(LocaleKeys.introduction.tr()),
                            const SizedBox(height: 8),
                            DefaultField(
                              onFocus: (isFocused) {
                                "isFocused: value is $isFocused".log();
                                if (isFocused) {
                                  _scrollController.animateTo(
                                    _scrollController.position.minScrollExtent,
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeIn,
                                  );
                                }
                              },
                              initialValue: userProfile.introduction,
                              hintText: LocaleKeys.enterYourIntroduction.tr(),
                              isBorderType: true,
                              onChange: (text) {
                                setState(() {
                                  introduction = text;
                                });
                              },
                              onEditingComplete: () {
                                // unfocus and close the Soft Key Board
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                            ),
                            const VerticalSpace(25),
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              LocaleKeys.visitStatusDisclosure
                                                  .tr(),
                                              style: fontCompactMd(),
                                            ),
                                            const HorizontalSpace(5),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isShowToolTip =
                                                      !_isShowToolTip;
                                                });
                                              },
                                              child: DefaultImage(
                                                path:
                                                    "assets/icons/ic_Info_bold.svg",
                                                width: 20,
                                                height: 20,
                                                color: white,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            isLocationPublic
                                                ? Text(
                                                    LocaleKeys.iWillRevealIt
                                                        .tr(),
                                                    style: fontCompactSm(),
                                                  )
                                                : Text(
                                                    LocaleKeys.iWillHideIt.tr(),
                                                    style: fontCompactSm(),
                                                  ),
                                            const HorizontalSpace(5),
                                            CustomToggle(
                                              initialValue: isLocationPublic,
                                              onTap: (bool value) {
                                                setState(() {
                                                  isLocationPublic = value;
                                                });
                                              },
                                              toggleColor: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    buildDividerEditMembershipLink(context),
                                    const VerticalSpace(25),
                                  ],
                                ),
                                if (_isShowToolTip)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InfoTextToolTipWidget(
                                      title:
                                          LocaleKeys.locationAgreeInfoText.tr(),
                                      onTap: () {
                                        setState(() {
                                          _isShowToolTip = false;
                                        });
                                      },
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: HMPCustomButton(
                      text: LocaleKeys.saveTitle.tr(),
                      onPressed: () {
                        if (widget.nickNameState.nickNameError) {
                          context.showErrorSnackBar(
                              LocaleKeys.nickNameIsAlreadyUsed.tr());
                        } else if (nickName.isEmpty || introduction.isEmpty) {
                          context.showErrorSnackBar(
                              LocaleKeys.inputFieldsAreEmpty.tr());
                        } else {
                          getIt<ProfileCubit>().onUpdateUserProfile(
                            UpdateProfileRequestDto(
                              nickName: nickName.isEmpty
                                  ? userProfile.nickName
                                  : nickName,
                              introduction: introduction.isEmpty
                                  ? userProfile.introduction
                                  : introduction,
                              locationPublic: (isLocationPublic !=
                                      userProfile.locationPublic)
                                  ? isLocationPublic
                                  : userProfile.locationPublic,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Row buildInputLabelText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: fontBodySmMedium(),
        ),
        const SizedBox(width: 5),
        // A 4 by 4 hmpBlue Color Dot,
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 4,
          height: 4,
          decoration:
              const BoxDecoration(color: hmpBlue, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget buildDividerEditMembershipLink(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: bgNega5),
          ),
          GestureDetector(
            onTap: () {
              getIt<NftCubit>().onGetNftCollections();
              MyMembershipSettingsScreen.push(context);
            },
            child: Text(
              LocaleKeys.myMembershipSettings.tr(),
              style: fontCompactMd(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageWidget(
    BuildContext context,
    UserProfileEntity userProfile,
  ) {
    return GestureDetector(
      onTap: () {
        getIt<NftCubit>().onGetSelectedNftTokens();
        SelectProfileImageScreen.push(context, userProfile);
      },
      child: Center(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: userProfile.pfpImageUrl.isNotEmpty
                  ? CustomImageView(
                      url: userProfile.pfpImageUrl,
                      fit: BoxFit.fill,
                      width: 88,
                      height: 88,
                    )
                  : DefaultImage(
                      path: "assets/images/launcher-icon.png",
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
      ),
    );
  }

  /// Section Widget
}

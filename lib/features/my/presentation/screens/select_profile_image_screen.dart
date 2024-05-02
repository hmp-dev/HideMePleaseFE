import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/helpers/helper_functions.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/infrastructure/dtos/update_profile_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/my/presentation/cubit/profile_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class SelectProfileImageScreen extends StatefulWidget {
  const SelectProfileImageScreen({super.key, required this.userProfile});

  final UserProfileEntity userProfile;

  static push(BuildContext context, UserProfileEntity userProfile) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectProfileImageScreen(userProfile: userProfile),
      ),
    );
  }

  @override
  State<SelectProfileImageScreen> createState() =>
      _SelectProfileImageScreenState();
}

class _SelectProfileImageScreenState extends State<SelectProfileImageScreen> {
  int selectedIndex = 0;
  bool isAnImageSelected = false;

  @override
  void initState() {
    super.initState();
  }

  List<String> pfpImages = [
    "assets/images/pfp1.png",
    "assets/images/pfp2.png",
    "assets/images/pfp3.png",
    "assets/images/pfp4.png",
    "assets/images/pfp5.png",
    "assets/images/pfp6.png",
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.selectProfileImage.tr(),
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      bottomNavigationBar: Container(
        color: Colors.black.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: HMPCustomButton(
          text: LocaleKeys.confirm.tr(),
          onPressed: () {
            final selectedNfts = getIt<NftCubit>().state.selectedNftTokensList;
            getIt<ProfileCubit>().onUpdateUserProfile(UpdateProfileRequestDto(
                pfpNftId: selectedNfts[selectedIndex].id));
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocConsumer<NftCubit, NftState>(
            bloc: getIt<NftCubit>(),
            listener: (context, state) {},
            builder: (context, state) {
              final selectedNfts = state.selectedNftTokensList;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CustomImageView(
                        url: isAnImageSelected
                            ? selectedNfts[selectedIndex].imageUrl
                            : widget.userProfile.pfpImageUrl,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        color: Colors.black45.withOpacity(0.5),
                      ),
                      ClipOval(
                        child: CustomImageView(
                          url: isAnImageSelected
                              ? selectedNfts[selectedIndex].imageUrl
                              : widget.userProfile.pfpImageUrl,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ],
                  ),
                  const VerticalSpace(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          "${formatDate(DateTime.now())} 기준",
                          style: fontCompactSm(color: fore3),
                        ),
                      ),
                    ],
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(5.0),
                    itemCount: selectedNfts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isAnImageSelected = true;
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: index == selectedIndex
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          child: CustomImageView(
                            url: selectedNfts[index].imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Section Widget
}

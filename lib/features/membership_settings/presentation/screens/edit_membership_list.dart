import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_nft_item.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class EditMembershipListScreen extends StatefulWidget {
  const EditMembershipListScreen({
    super.key,
    required this.isShowMembershipButton,
  });

  final bool isShowMembershipButton;

  static push(BuildContext context, bool isShowMembershipButton) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMembershipListScreen(
            isShowMembershipButton: isShowMembershipButton),
      ),
    );
  }

  @override
  State<EditMembershipListScreen> createState() =>
      _EditMembershipListScreenState();
}

class _EditMembershipListScreenState extends State<EditMembershipListScreen> {
  @override
  void dispose() {
    getIt<NftCubit>().onCollectionOrderChanged();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.editMembershipList.tr(),
      isCenterTitle: true,
      backIconPath: "assets/icons/ic_close.svg",
      onBack: () {
        Navigator.pop(context);
      },
      body: SafeArea(
        top: false,
        bottom: true,
        child: BlocConsumer<NftCubit, NftState>(
          bloc: getIt<NftCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: state.isSubmitLoading
                      ? const SizedBox.shrink()
                      : state.isSubmitFailure
                          ? const Center(child: Text("Something went wrong"))
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ReorderableListView.builder(
                                      buildDefaultDragHandles: false,
                                      shrinkWrap: true,
                                      itemCount:
                                          state.selectedNftTokensList.length,
                                      itemBuilder: (context, index) {
                                        final nft =
                                            state.selectedNftTokensList[index];
                                        final imageUrl = nft.imageUrl;
                                        final name = nft.name;
                                        final chain = nft.chain.toLowerCase();

                                        return SelectedNftItem(
                                          key: ValueKey(
                                              '${nft.id}-${nft.tokenAddress}-$index'),
                                          index: index,
                                          imageUrl: imageUrl,
                                          name: name,
                                          chain: chain,
                                        );
                                      },
                                      onReorder: (oldIndex, newIndex) {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final item = state.selectedNftTokensList
                                            .removeAt(oldIndex);

                                        state.selectedNftTokensList
                                            .insert(newIndex, item);
                                      },
                                    ),
                                  ),

                                  const VerticalSpace(20),

                                  // show Membership Button
                                  //of if isShowMembershipButton is true
                                  widget.isShowMembershipButton
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            buildMyMembershipSettingsTextIconButton(),
                                            const VerticalSpace(10),
                                            HMPCustomButton(
                                              text: LocaleKeys.confirm.tr(),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                ),
                if (!widget.isShowMembershipButton)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RoundedButtonWithBorder(
                              text: LocaleKeys.previous.tr(),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const HorizontalSpace(10),
                          Expanded(
                            child: HMPCustomButton(
                              text: LocaleKeys.next.tr(),
                              onPressed: () {
                                getIt<NftCubit>().onCollectionOrderChanged();

                                // Navigate to Home
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.appHome,
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMyMembershipSettingsTextIconButton() {
    return GestureDetector(
      onTap: () {
        // call to get nft collections
        getIt<NftCubit>().onGetNftCollections();
        // Navigate to Membership Settings
        MyMembershipSettingsScreen.push(context);
      },
      child: Container(
        width: double.infinity,
        height: 60,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.myMembershipSettings.tr(),
              style: fontCompactSm(color: fore2),
            ),
            const SizedBox(width: 5),
            DefaultImage(
              path: "assets/icons/arrow_right.svg",
              width: 14,
              height: 14,
            ),
          ],
        ),
      ),
    );
  }
}

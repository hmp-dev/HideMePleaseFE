import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/empty_data_widget.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_nft_item.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/generated/locale_keys.g.dart';

/// A screen that allows the user to edit their membership list.
///
/// The screen shows a list of NFT tokens that the user has added to their
/// membership list. The user can select and rearrange the tokens in the
/// list. The screen also provides a button to add more tokens to the
/// membership list.
class EditMembershipListScreen extends StatefulWidget {
  // Constructor
  /// Creates a new instance of [EditMembershipListScreen].
  ///
  /// The [isShowMembershipButton] parameter determines whether the "Add
  /// Membership" button should be displayed on the screen.
  const EditMembershipListScreen({
    super.key,
    required this.isShowMembershipButton,
  });

  /// Determines whether the "Add Membership" button should be displayed on
  /// the screen.
  final bool isShowMembershipButton;

  /// Pushes an instance of [EditMembershipListScreen] onto the navigation
  /// stack and returns the result of the push.
  ///
  /// The [isShowMembershipButton] parameter determines whether the "Add
  /// Membership" button should be displayed on the screen.
  static Future<dynamic> push(
      BuildContext context, bool isShowMembershipButton) async {
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

  /// Builds the widget tree for the `EditMembershipListScreen`.
  ///
  /// This function returns a `BaseScaffold` widget that contains a `Stack` widget
  /// with multiple children. The `BaseScaffold` widget is used to display a
  /// title, a back button, and a body widget. The body widget is a `SafeArea`
  /// widget that contains a `BlocConsumer` widget. The `BlocConsumer` widget
  /// listens to changes in the `NftCubit` state and rebuilds the widget tree
  /// based on the state.
  ///
  /// The `Stack` widget contains a `SizedBox` widget as its first child. The
  /// `SizedBox` widget has a width that is equal to the width of the screen.
  /// If the `submitStatus` of the `NftCubit` state is `loading`, a
  /// `Center` widget with a `Lottie.asset` widget is displayed. If the
  /// `submitStatus` is `failure`, a `Center` widget with an `EmptyDataWidget`
  /// is displayed. Otherwise, a `Padding` widget is displayed. The `Padding`
  /// widget contains a `Column` widget with multiple children. The `Column`
  /// widget contains an `Expanded` widget with a `ReorderableListView.builder`
  /// widget as its child. The `ReorderableListView.builder` widget builds a list
  /// of `SelectedNftItem` widgets based on the `selectedNftTokensList` in the
  /// `NftState`. The `SelectedNftItem` widget displays information about an NFT
  /// token. The `ReorderableListView.builder` widget also handles the reordering
  /// of the NFT tokens.
  ///
  /// If the `isShowMembershipButton` parameter is `true`, a `Column` widget is
  /// displayed with a `buildMyMembershipSettingsTextIconButton` widget and a
  /// `HMPCustomButton` widget. The `HMPCustomButton` widget is used to confirm
  /// the selection of NFT tokens.
  ///
  /// If the `isShowMembershipButton` parameter is `false`, an `Align` widget is
  /// displayed with a `Padding` widget as its child. The `Padding` widget
  /// contains a `Row` widget with two `Expanded` widgets. The first `Expanded`
  /// widget contains a `RoundedButtonWithBorder` widget with a "Previous"
  /// button. The second `Expanded` widget contains an `HMPCustomButton` widget
  /// with a "Next" button.
  ///
  /// The `build` function takes a `BuildContext` parameter and returns a
  /// `Widget` tree.
  ///
  /// Parameters:
  /// - `context`: The `BuildContext` of the widget tree.
  ///
  /// Returns:
  /// A `Widget` tree that represents the `EditMembershipListScreen`.
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
                  child: state.submitStatus == RequestStatus.loading
                      ? Center(
                          child: Lottie.asset(
                            'assets/lottie/loader.json',
                          ),
                        )
                      : state.submitStatus == RequestStatus.failure
                          ? const Center(child: EmptyDataWidget())
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
                                  Routes.appScreen,
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

  /// Builds a GestureDetector widget that, when tapped, calls to get nft collections and navigates to the MyMembershipSettingsScreen.
  ///
  /// Returns a GestureDetector widget containing a Container with a Row of a Text widget and a DefaultImage widget.
  ///
  /// The GestureDetector has an onTap callback that calls getIt<NftCubit>().onGetNftCollections() and MyMembershipSettingsScreen.push(context).
  ///
  /// The Container has a width of double.infinity, a height of 60, and a color of Colors.transparent.
  ///
  /// The Row has a mainAxisAlignment of MainAxisAlignment.center and a crossAxisAlignment of CrossAxisAlignment.center.
  ///
  /// The Text widget displays the localized string for MyMembershipSettings and has a style of fontCompactSm with a color of fore2.
  ///
  /// The DefaultImage widget displays the arrow_right.svg asset and has a width and height of 14.
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/features/nft/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/selected_nft_item.dart';
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
  void initState() {
    super.initState();
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
        child: BlocConsumer<NftCubit, NftState>(
          bloc: getIt<NftCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: state.isLoading
                        ? const SizedBox.shrink()
                        : state.isFailure
                            ? const Center(child: Text("Something went wrong"))
                            : Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ReorderableListView.builder(
                                      key: UniqueKey(),
                                      shrinkWrap: true,
                                      itemCount:
                                          state.selectedNftTokensList.length,
                                      itemBuilder: (context, index) {
                                        final nft =
                                            state.selectedNftTokensList[index];
                                        final imageUrl = nft.imageUrl;
                                        final name = nft.name;
                                        final chain = nft.chain.toLowerCase();

                                        //
                                        return ReorderableDelayedDragStartListener(
                                          key: ValueKey(nft),
                                          index: index,
                                          child: SelectedNftItem(
                                            key: ValueKey(nft),
                                            imageUrl: imageUrl,
                                            name: name,
                                            chain: chain,
                                          ),
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

                                    const VerticalSpace(20),

                                    // show Membership Button
                                    //of if isShowMembershipButton is true
                                    widget.isShowMembershipButton
                                        ? HMPCustomButton(
                                            text: LocaleKeys
                                                .myMembershipSettings
                                                .tr(),
                                            onPressed: () {
                                              // call to get nft collections
                                              getIt<NftCubit>()
                                                  .onGetNftCollections();
                                              // Navigate to Membership Settings
                                              MyMembershipSettingsScreen.push(
                                                  context);
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                  ),
                ),
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
                              List<String> order = [];

                              for (var nft in state.selectedNftTokensList) {
                                order.add(nft.id);
                              }

                              getIt<NftCubit>().onPostCollectionOrderSave(
                                  saveSelectedTokensReorderRequestDto:
                                      SaveSelectedTokensReorderRequestDto(
                                          order: order));

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
}

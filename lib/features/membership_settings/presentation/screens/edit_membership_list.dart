import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/core/router/router.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/infrastructure/dtos/save_selected_token_reorder_request_dto.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/rounded_button_with_border.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/my_membership_settings.dart';
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

class _EditMembershipListScreenState extends State<EditMembershipListScreen>
    with TickerProviderStateMixin {
  late TabController tabViewController;

  List<String> tasks = [
    "A Task",
    "B Task",
    "C Task",
    "D Task",
    "E Task",
    "F Task",
    "G Task",
    "H Task"
  ];

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.editMembershipList.tr(),
      isCenterTitle: true,
      backIconPath: "assets/icons/ic_cancel.svg",
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
                        const HorizontalSpace(20),
                        Expanded(
                          child: HMPCustomButton(
                            text: LocaleKeys.next.tr(),
                            onPressed: () {
                              List<String> order = [];

                              for (var nft in state.selectedNftTokensList) {
                                order.add(nft.id);
                              }

                              Log.info(order);

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

class SelectedNftItem extends StatelessWidget {
  const SelectedNftItem(
      {super.key,
      required this.imageUrl,
      required this.name,
      required this.chain});

  final String imageUrl;
  final String name;
  final String chain;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    imageUrl != ""
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 63,
                            height: 64,
                          )
                        : DefaultImage(
                            path: "assets/images/home_card_img.png",
                            width: 63,
                            height: 64,
                            boxFit: BoxFit.cover,
                          ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: DefaultImage(
                        path: "assets/images/${chain}_logo.svg",
                        width: 16,
                        height: 16,
                      ),
                    )
                  ],
                ),
                const HorizontalSpace(20),
                SizedBox(
                  width: 100,
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: fontBodyMdBold(),
                  ),
                )
              ],
            ),
            DefaultImage(
              path: "assets/icons/ic_drag_bars.svg",
              color: fore1,
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Divider(),
        )
      ],
    );
  }
}

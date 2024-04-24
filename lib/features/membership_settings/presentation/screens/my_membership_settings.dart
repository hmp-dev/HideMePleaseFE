import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/logger/logger.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/common/presentation/widgets/large_button.dart';
import 'package:mobile/features/common/presentation/widgets/rounder_button_small.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class MyMembershipSettingsScreen extends StatefulWidget {
  const MyMembershipSettingsScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyMembershipSettingsScreen(),
      ),
    );
  }

  @override
  State<MyMembershipSettingsScreen> createState() =>
      _MyMembershipSettingsScreenState();
}

class _MyMembershipSettingsScreenState extends State<MyMembershipSettingsScreen>
    with TickerProviderStateMixin {
  late TabController tabViewController;

  @override
  void initState() {
    super.initState();
    tabViewController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.myMembershipSettings.tr(),
      isCenterTitle: true,
      backIconPath: "assets/icons/ic_cancel.svg",
      onBack: () {
        Navigator.pop(context);
      },
      suffix: GestureDetector(
        onTap: () {
          Log.info("Info Icon is tapped");
        },
        child: DefaultImage(
          path: "assets/icons/ic_Info_bold.svg",
          width: 24,
          height: 24,
          color: white,
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<NftCubit, NftState>(
          bloc: getIt<NftCubit>(),
          listener: (context, state) {},
          builder: (context, state) {
            return SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: state.isLoading
                    ? const SizedBox.shrink()
                    : state.isFailure
                        ? const Center(child: Text("Something went wrong"))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 32),
                              buildLinkedWalletWidget(context),
                              const SizedBox(height: 20),
                              Container(
                                margin: const EdgeInsets.only(left: 16),
                                height: 50,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    BlockChainSelectButton(
                                      title: LocaleKeys.all.tr(),
                                      isSelected: true,
                                      onTap: () {},
                                    ),
                                    BlockChainSelectButton(
                                      title: "Ethereum",
                                      isSelected: false,
                                      onTap: () {},
                                    ),
                                    BlockChainSelectButton(
                                      title: "Solana",
                                      isSelected: false,
                                      onTap: () {},
                                    ),
                                    BlockChainSelectButton(
                                      title: "Polygon",
                                      isSelected: false,
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                              const VerticalSpace(25),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.nftCollectionsGroupEntity
                                    .collections.length,
                                itemBuilder: (context, index) {
                                  final collectionName = state
                                      .nftCollectionsGroupEntity
                                      .collections[index]
                                      .name;

                                  final chainSymbol = state
                                      .nftCollectionsGroupEntity
                                      .collections[index]
                                      .chainSymbol;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CollectionTitleWidget(
                                        title: collectionName,
                                        chainSymbol: chainSymbol,
                                      ),
                                      const VerticalSpace(25),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 20, bottom: 25),
                                        height: 130,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state
                                              .nftCollectionsGroupEntity
                                              .collections[index]
                                              .tokens
                                              .length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: state
                                                      .nftCollectionsGroupEntity
                                                      .collections[index]
                                                      .tokens[index]
                                                      .imageUrl,
                                                  width: 100,
                                                  height: 100,
                                                ),
                                                const VerticalSpace(10),
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    state
                                                        .nftCollectionsGroupEntity
                                                        .collections[index]
                                                        .tokens[index]
                                                        .name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: fontM(12),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: LargeButton(
                                  text: LocaleKeys.next.tr(),
                                  onPressed: () {},
                                ),
                              )
                            ],
                          ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildLinkedWalletWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 100,
            decoration: BoxDecoration(
              color: black500,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.linkedWallet.tr(),
                        style: fontSB(16),
                      ),
                      const VerticalSpace(10),
                      DefaultImage(
                          path: "assets/images/metamask_wallet_icon.svg")
                    ],
                  ),
                  RoundedButtonSmall(
                      title: LocaleKeys.addWallet.tr(), onTap: () {})
                ],
              ),
            ),
          ),
          const VerticalSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "MM/DD hh:mm 기준",
                style: fontR(12),
              ),
              const HorizontalSpace(3),
              DefaultImage(
                path: "assets/icons/ic_arrow_clockwise.svg",
                color: white,
                height: 16,
              )
            ],
          )
        ],
      ),
    );
  }
}

class CollectionTitleWidget extends StatelessWidget {
  final String title;
  final String chainSymbol;

  const CollectionTitleWidget({
    super.key,
    required this.title,
    required this.chainSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          DefaultImage(
            path: "assets/icons/ethereum_chain_icon.svg",
            width: 40,
            height: 40,
          ),
          const HorizontalSpace(15),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              title,
              //"London Underground Station(LUS) 264 Genesis",
              overflow: TextOverflow.ellipsis,
              style: fontSB(18),
            ),
          )
        ],
      ),
    );
  }
}

class BlockChainSelectButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const BlockChainSelectButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3D3D3E) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border:
                isSelected ? null : Border.all(color: const Color(0xFF3D3D3E)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
            child: Center(
              child: Text(
                title,
                style: fontSB(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

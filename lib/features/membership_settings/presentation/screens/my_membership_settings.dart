import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/enum/chain_type.dart';
import 'package:mobile/app/core/enum/error_codes.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/default_snackbar.dart';
import 'package:mobile/features/common/presentation/widgets/empty_data_widget.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/common/presentation/widgets/info_text_tool_tip_widget.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/membership_settings/presentation/screens/edit_membership_list.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/block_chain_select_button.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/collection_title_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/connected_wallets_widget.dart';
import 'package:mobile/features/membership_settings/presentation/widgets/nft_token_widget.dart';
import 'package:mobile/features/nft/infrastructure/dtos/select_token_toggle_request_dto.dart';
import 'package:mobile/features/nft/presentation/cubit/nft_cubit.dart';
import 'package:mobile/features/wallets/presentation/cubit/wallets_cubit.dart';
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

class _MyMembershipSettingsScreenState
    extends State<MyMembershipSettingsScreen> {
  bool _isShowToolTip = false;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Attach listener to the scroll controller
    _scrollController.addListener(_onScroll);
  }

  // Method to handle scrolling
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMoreData();
    }
  }

  // Method to load more data
  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    getIt<NftCubit>().onGetNftCollections(isLoadMoreFetch: true);

    // call cubit

    setState(() {
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    getIt<NftCubit>().onGetNftCollections();
    getIt<NftCubit>().onGetSelectedNftTokens();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: LocaleKeys.myMembershipSettings.tr(),
      isCenterTitle: true,
      backIconPath: "assets/icons/ic_close.svg",
      onBack: () {
        Navigator.pop(context);
      },
      suffix: GestureDetector(
        onTap: () {
          setState(() {
            _isShowToolTip = !_isShowToolTip;
          });
        },
        child: DefaultImage(
          path: "assets/icons/ic_info.svg",
          width: 32,
          height: 32,
          color: white,
        ),
      ),
      body: SafeArea(
        child: BlocListener<WalletsCubit, WalletsState>(
          bloc: getIt<WalletsCubit>(),
          listener: (context, state) {
            if (state.submitStatus == RequestStatus.failure) {
              // Map the error message to the appropriate enum message
              String errorMessage = getErrorMessage(state.errorMessage);

              // Show Error Snackbar If Wallet is Already Connected
              context.showErrorSnackBarDismissible(errorMessage);

              "inside listener++++++ error message is $errorMessage".log();
            }
          },
          child: BlocConsumer<NftCubit, NftState>(
            bloc: getIt<NftCubit>(),
            listener: (context, state) {},
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: state.isSubmitLoading
                        ? SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: const SizedBox.shrink(),
                            ),
                          )
                        : CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              const SliverToBoxAdapter(
                                  child: ConnectedWalletsWidget()),
                              const SliverToBoxAdapter(
                                  child: SizedBox(height: 20)),
                              SliverToBoxAdapter(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 20),
                                  height: 50,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      BlockChainSelectButton(
                                        title: LocaleKeys.all.tr(),
                                        isSelected: state.selectedChain ==
                                            ChainType.ALL.name,
                                        onTap: () {
                                          getIt<NftCubit>().onGetNftCollections(
                                              chain: ChainType.ALL.name,
                                              isChainTypeFetchTapped: true);
                                        },
                                      ),
                                      BlockChainSelectButton(
                                        title: ChainType.ETHEREUM.label,
                                        imagePath: ChainType.ETHEREUM.chainLogo,
                                        isSelected: state.selectedChain ==
                                            ChainType.ETHEREUM.name,
                                        onTap: () {
                                          getIt<NftCubit>().onGetNftCollections(
                                            chain: ChainType.ETHEREUM.name,
                                            isChainTypeFetchTapped: true,
                                          );
                                        },
                                      ),
                                      BlockChainSelectButton(
                                        title: ChainType.POLYGON.label,
                                        imagePath: ChainType.POLYGON.chainLogo,
                                        isSelected: state.selectedChain ==
                                            ChainType.POLYGON.name,
                                        onTap: () {
                                          getIt<NftCubit>().onGetNftCollections(
                                            chain: ChainType.POLYGON.name,
                                            isChainTypeFetchTapped: true,
                                          );
                                        },
                                      ),
                                      BlockChainSelectButton(
                                        title: ChainType.SOLANA.label,
                                        imagePath: ChainType.SOLANA.chainLogo,
                                        isSelected: state.selectedChain ==
                                            ChainType.SOLANA.name,
                                        onTap: () {
                                          getIt<NftCubit>().onGetNftCollections(
                                            chain: ChainType.SOLANA.name,
                                            isChainTypeFetchTapped: true,
                                          );
                                        },
                                      ),
                                      BlockChainSelectButton(
                                        title: ChainType.KLAYTN.label,
                                        imagePath: ChainType.KLAYTN.chainLogo,
                                        isSelected: state.selectedChain ==
                                            ChainType.KLAYTN.name,
                                        onTap: () {
                                          getIt<NftCubit>().onGetNftCollections(
                                            chain: ChainType.KLAYTN.name,
                                            isChainTypeFetchTapped: true,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                  child: VerticalSpace(25)),
                              (state.nftCollectionsGroupEntity.collections
                                      .isEmpty)
                                  ? const SliverToBoxAdapter(
                                      child: Column(
                                      children: [
                                        Center(child: EmptyDataWidget()),
                                      ],
                                    ))
                                  : SliverList.builder(
                                      itemCount: state.nftCollectionsGroupEntity
                                          .collections.length,
                                      itemBuilder: (context, collectionIndex) {
                                        final collection = state
                                            .nftCollectionsGroupEntity
                                            .collections[collectionIndex];

                                        final collectionName = state
                                            .nftCollectionsGroupEntity
                                            .collections[collectionIndex]
                                            .name;

                                        final chainSymbol = state
                                            .nftCollectionsGroupEntity
                                            .collections[collectionIndex]
                                            .chainSymbol;

                                        return Column(
                                          key: ValueKey(
                                              '$collectionName-$chainSymbol-$collectionIndex'),
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
                                              height: 190,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: state
                                                    .nftCollectionsGroupEntity
                                                    .collections[
                                                        collectionIndex]
                                                    .tokens
                                                    .length,
                                                itemBuilder:
                                                    (context, tokenIndex) {
                                                  final nftTokenEntity =
                                                      collection
                                                          .tokens[tokenIndex];

                                                  return NftTokenWidget(
                                                    onTap: () {
                                                      getIt<NftCubit>()
                                                          .onSelectDeselectNftToken(
                                                        collectionIndex:
                                                            collectionIndex,
                                                        requestDto:
                                                            SelectTokenToggleRequestDto(
                                                          nftId:
                                                              nftTokenEntity.id,
                                                          selected:
                                                              !nftTokenEntity
                                                                  .selected,
                                                          order:
                                                              collectionIndex,
                                                        ),
                                                        selectedNft:
                                                            nftTokenEntity,
                                                        selected:
                                                            !nftTokenEntity
                                                                .selected,
                                                      );
                                                    },
                                                    key: ValueKey(
                                                        '$collectionName-$chainSymbol-$collectionIndex-${collection.tokenAddress}-$tokenIndex'),
                                                    tokenOrder: collectionIndex,
                                                    nftTokenEntity:
                                                        nftTokenEntity,
                                                    tokenAddress:
                                                        collection.tokenAddress,
                                                    walletAddress:
                                                        collection.tokenAddress,
                                                    chain: collection.chain,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                              (state.isLoadingMore)
                                  ? SliverToBoxAdapter(
                                      child: Lottie.asset(
                                        'assets/lottie/loader.json',
                                      ),
                                    )
                                  : const SliverToBoxAdapter(
                                      child: SizedBox(height: 100)),
                            ],
                          ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, bottom: 20),
                      child: HMPCustomButton(
                        text:
                            "${LocaleKeys.next.tr()} (${state.selectedCollectionCount}/${state.maxSelectableCount})",
                        onPressed: () {
                          getIt<NftCubit>().onGetSelectedNftTokens();
                          EditMembershipListScreen.push(context, false);
                        },
                      ),
                    ),
                  ),
                  if (_isShowToolTip)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InfoTextToolTipWidget(
                        title:
                            "보유한 NFT 컬렉션의 대표 NFT를 설정하세요.설정은 최대 20개 컬렉션에서 각 1개씩 가능합니다. 대표 NFT가 속한 컬렉션은 1개의 혜택을 제공합니다.",
                        onTap: () {
                          setState(() {
                            _isShowToolTip = false;
                          });
                        },
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

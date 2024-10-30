import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/community/domain/entities/nft_community_entity.dart';
import 'package:mobile/features/community/infrastructure/dtos/nft_community_dto.dart';
import 'package:mobile/features/community/presentation/widgets/free_nft_redeem_view.dart';
import 'package:mobile/features/community/presentation/widgets/get_free_nft_view.dart';
import 'package:mobile/features/community/presentation/widgets/hot_communities_view.dart';
import 'package:mobile/features/community/presentation/widgets/nft_community_card_widget.dart';
import 'package:mobile/features/community/presentation/widgets/user_communities_view.dart';
import 'package:mobile/features/nft/domain/entities/welcome_nft_entity.dart';
import 'package:mobile/features/wepin/wepin_wallet_connect_list_tile.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class CommunityView extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final void Function(NftCommunityEntity) onCommunityTap;
  final void Function(NftCommunityEntity) onEnterChat;
  final VoidCallback onConnectWallet;
  final VoidCallback onGetFreeNft;
  final List<NftCommunityEntity> allNftCommunities;
  final int communityCount;
  final int itemCount;
  final List<NftCommunityEntity> hotNftCommunities;
  final List<NftCommunityEntity> userNftCommunities;
  final GetNftCommunityOrderBy allNftCommOrderBy;
  final bool isWalletConnected;
  final bool redeemedFreeNft;
  final WelcomeNftEntity welcomeNft;
  final GetNftCommunityOrderBy orderBy;
  final void Function(GetNftCommunityOrderBy?) onOrderByChanged;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  const CommunityView({
    super.key,
    required this.onRefresh,
    required this.onCommunityTap,
    required this.onEnterChat,
    required this.onConnectWallet,
    required this.onGetFreeNft,
    required this.allNftCommunities,
    required this.communityCount,
    required this.itemCount,
    required this.hotNftCommunities,
    required this.userNftCommunities,
    required this.allNftCommOrderBy,
    required this.isWalletConnected,
    required this.redeemedFreeNft,
    required this.welcomeNft,
    required this.orderBy,
    required this.onOrderByChanged,
    required this.onLoadMore,
    required this.isLoadingMore,
  });

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(child: buildTopTitleBar()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (widget.isWalletConnected && widget.userNftCommunities.isNotEmpty)
            SliverToBoxAdapter(
              child: UserCommunitiesView(
                onTap: widget.onCommunityTap,
                onEnterChat: widget.onEnterChat,
                userNftCommunities: widget.userNftCommunities,
              ),
            )
          else if (widget.isWalletConnected &&
              widget.userNftCommunities.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FreeNftRedeemView(
                  totalNfts: widget.welcomeNft.totalNfts,
                  redeemedNfts: widget.welcomeNft.redeemedNfts,
                  remainingNfts: widget.welcomeNft.remainingNfts,
                  bgImage: widget.welcomeNft.image,
                  name: widget.welcomeNft.name,
                  onTap: widget.onGetFreeNft,
                ),
              ),
            )
          else if (!widget.isWalletConnected)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: WepinWalletConnectLisTile(
                    isShowCommunityWelcomeNFTRedeemButton: true),

                // GetFreeNftView(
                //   onTap: widget.onConnectWallet,
                // ),
              ),
            ),
          if (widget.hotNftCommunities.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HotCommunitiesView(
                  onCommunityTap: widget.onCommunityTap,
                  hotNftCommunities: widget.hotNftCommunities,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AllCommunitiesHeader(
                  orderBy: widget.orderBy,
                  onOrderByChanged: widget.onOrderByChanged,
                  communityCount: widget.communityCount),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverGrid.builder(
            itemCount: widget.allNftCommunities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 20.0,
            ),
            itemBuilder: (_, index) {
              return Container(
                padding: index % 2 == 0
                    ? const EdgeInsets.only(left: 20)
                    : const EdgeInsets.only(right: 20),
                child: NftCommunityCardWidget(
                  onTap: () =>
                      widget.onCommunityTap(widget.allNftCommunities[index]),
                  title: widget.allNftCommunities[index].name,
                  networkLogo: widget.allNftCommunities[index].chainLogo,
                  imagePath: widget.allNftCommunities[index].collectionLogo,
                  people: widget.allNftCommunities[index].people,
                  rank: widget.allNftCommunities[index].rank,
                  timeAgo: widget.allNftCommunities[index].timeAgo,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: widget.isLoadingMore
                ? Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    height: 50,
                    color: Colors.transparent, // Adjust height if needed
                    child: Lottie.asset(
                      'assets/lottie/loader.json',
                      fit: BoxFit.contain, // Or BoxFit.cover
                    ),
                  )
                : const SizedBox(
                    height: 60,
                  ),
          ),
        ],
      ),
    );
  }

  Container buildTopTitleBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      height: 75,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text("Chat me", style: fontBody2Bold()),
            Text("Community", style: fontBody2Bold()),
            const AlarmsIconButton(),
          ],
        ),
      ),
    );
  }
}

class AllCommunitiesHeader extends StatelessWidget {
  const AllCommunitiesHeader({
    super.key,
    required this.communityCount,
    required this.orderBy,
    required this.onOrderByChanged,
  });

  final int communityCount;
  final GetNftCommunityOrderBy orderBy;
  final void Function(GetNftCommunityOrderBy?) onOrderByChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.allCommunity.tr(),
              style: fontTitle07Medium(),
            ),
            const SizedBox(width: 10),
            Text(
              communityCount.toString(),
              style: fontTitle07(color: fore2),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              value: orderBy,
              dropdownStyleData: const DropdownStyleData(
                  offset: Offset(-30, -20),
                  width: 100.0,
                  padding: EdgeInsets.zero),
              menuItemStyleData:
                  const MenuItemStyleData(padding: EdgeInsets.zero),
              items: GetNftCommunityOrderBy.values
                  .map((e) => DropdownMenuItem<GetNftCommunityOrderBy>(
                        value: e,
                        child: Container(
                          color: orderBy == e ? bg3 : bg1,
                          alignment: Alignment.center,
                          child: Text(
                            e == GetNftCommunityOrderBy.points
                                ? LocaleKeys.byPoints.tr()
                                : LocaleKeys.byMembers.tr(),
                            style: fontCompactSm(color: fore2),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: onOrderByChanged,
              customButton: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    orderBy == GetNftCommunityOrderBy.points
                        ? LocaleKeys.byPoints.tr()
                        : LocaleKeys.byMembers.tr(),
                    style: fontCompactSm(color: fore2),
                  ),
                  const SizedBox(width: 5),
                  DefaultImage(
                    path: "assets/icons/ic_arrow_down.svg",
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

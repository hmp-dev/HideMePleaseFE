import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/views/base_scaffold.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/community/presentation/widgets/community_error_view.dart';

class CommunityRankingView extends StatefulWidget {
  const CommunityRankingView({
    super.key,
    required this.onRetry,
    required this.onLoadMore,
    required this.topNfts,
    required this.isLoadingMore,
    required this.isLoading,
    required this.isError,
    required this.allLoaded,
  });

  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final List<TopCollectionNftEntity> topNfts;
  final bool isLoadingMore;
  final bool isLoading;
  final bool isError;
  final bool allLoaded;

  @override
  State<CommunityRankingView> createState() => _CommunityRankingViewState();
}

class _CommunityRankingViewState extends State<CommunityRankingView> {
  Timer? _paginationDebounceTimer;

  @override
  void dispose() {
    _paginationDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: '커뮤니티 랭킹',
      isCenterTitle: true,
      onBack: () {
        Navigator.pop(context);
      },
      body: widget.isLoading
          ? Lottie.asset(
              'assets/lottie/loader.json',
            )
          : widget.isError
              ? CommunityErrorView(onRetry: widget.onRetry)
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels ==
                            notification.metrics.maxScrollExtent &&
                        !widget.isLoadingMore) {
                      _paginationDebounceTimer?.cancel();
                      _paginationDebounceTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        widget.onLoadMore();
                      });
                    }
                    return true;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 16.0, 24.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                      child: widget.topNfts.length > 1
                                          ? _SecondaryRankItem(
                                              nft: widget.topNfts[1])
                                          : const SizedBox()),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                      child: widget.topNfts.isNotEmpty
                                          ? _PrimaryRankItem(
                                              nft: widget.topNfts[0])
                                          : const SizedBox()),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                      child: widget.topNfts.length > 2
                                          ? _SecondaryRankItem(
                                              nft: widget.topNfts[2])
                                          : const SizedBox()),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: CustomImageView(
                                svgPath: 'assets/icons/star_effects.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.topNfts.length > 3)
                        SliverList.separated(
                          itemCount: widget.topNfts.length - 3,
                          itemBuilder: (_, index) {
                            final nft = widget.topNfts[index + 3];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18.0, horizontal: 16.0),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text((nft.index + 1).toString(),
                                          style: fontCompactSmBold()),
                                      const SizedBox(height: 4.0),
                                      CustomImageView(
                                        svgPath: nft.pointFluctuation.isNegative
                                            ? "assets/icons/ic_arrow_down_blue.svg"
                                            : "assets/icons/ic_arrow_up_pink.svg",
                                        width: 8,
                                        height: 8,
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: 12.0),
                                  Stack(
                                    children: [
                                      CustomImageView(
                                        radius: BorderRadius.circular(4.0),
                                        url: nft.collectionLogo,
                                        height: 68.0,
                                        width: 48.0,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 4.0),
                                        child: CustomImageView(
                                          svgPath: nft.chainLogo,
                                          width: 14,
                                          height: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(nft.name,
                                            maxLines: 2,
                                            style: fontCompactMdBold()),
                                        const SizedBox(height: 4.0),
                                        Text('${nft.totalMembers}명이 함께함',
                                            maxLines: 2,
                                            style: fontCompactSm(color: fore2)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Text(nft.pointsFormatted,
                                      style: fontCompactMdBold()),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, index) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              height: 1.0,
                              width: double.infinity,
                              color: fore5.withOpacity(0.05),
                            );
                          },
                        ),
                      if (!widget.allLoaded)
                        SliverToBoxAdapter(
                          child: Lottie.asset('assets/lottie/loader.json'),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _SecondaryRankItem extends StatelessWidget {
  const _SecondaryRankItem({
    super.key,
    required this.nft,
  });

  final TopCollectionNftEntity nft;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text((nft.index + 1).toString(), style: fontCompactSmBold()),
            const SizedBox(width: 8.0),
            CustomImageView(
              svgPath: nft.pointFluctuation.isNegative
                  ? "assets/icons/ic_arrow_down_blue.svg"
                  : "assets/icons/ic_arrow_up_pink.svg",
              width: 8,
              height: 8,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Stack(
            children: [
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                url: nft.collectionLogo,
                fit: BoxFit.cover,
                height: 118.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                child: CustomImageView(
                  svgPath: nft.chainLogo,
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
        Text(nft.name, maxLines: 1, style: fontCompactSm()),
        const SizedBox(height: 2.0),
        Text(nft.pointsFormatted, maxLines: 1, style: fontCompactLgBold()),
      ],
    );
  }
}

class _PrimaryRankItem extends StatelessWidget {
  const _PrimaryRankItem({
    super.key,
    required this.nft,
  });

  final TopCollectionNftEntity nft;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomImageView(
          svgPath: 'assets/icons/topranker.svg',
          width: 64.0,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, .0, 8.0, 12.0),
          child: Stack(
            children: [
              CustomImageView(
                radius: BorderRadius.circular(4.0),
                url: nft.collectionLogo,
                fit: BoxFit.cover,
                height: 138.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                child: CustomImageView(
                  svgPath: nft.chainLogo,
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
        Text(nft.name, maxLines: 1, style: fontCompactSm()),
        const SizedBox(height: 2.0),
        Text(nft.pointsFormatted, maxLines: 1, style: fontCompactLgBold()),
      ],
    );
  }
}

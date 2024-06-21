import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_button.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/horizontal_space.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/community/presentation/widgets/community_error_view.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_network_entity.dart';

class CommunityDetailsView extends StatelessWidget {
  final VoidCallback onEnterChat;
  final VoidCallback onRetry;
  final VoidCallback onTapRank;
  final void Function(CommunityMemberEntity) onMemberTap;
  final TopCollectionNftEntity nftEntity;
  final int benefitCount;
  final List<BenefitEntity> nftBenefits;
  final int membersCount;
  final List<CommunityMemberEntity> communityMembers;
  final NftNetworkEntity nftNetwork;
  final bool infoLoading;
  final bool infoError;
  final bool membersLoading;
  final bool membersError;

  const CommunityDetailsView({
    super.key,
    required this.onEnterChat,
    required this.onRetry,
    required this.onTapRank,
    required this.onMemberTap,
    required this.nftEntity,
    required this.benefitCount,
    required this.nftBenefits,
    required this.membersCount,
    required this.communityMembers,
    required this.nftNetwork,
    required this.infoLoading,
    required this.infoError,
    required this.membersLoading,
    required this.membersError,
  });

  @override
  Widget build(BuildContext context) {
    final koreanNumFormat = NumberFormat("###,###,###", "en_US");

    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 260.0,
              collapsedHeight: 80.0,
              floating: true,
              snap: true,
              pinned: true,
              backgroundColor: bg1,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: DefaultImage(
                  path: "assets/icons/arrow_back.svg",
                  width: 32,
                  height: 32,
                ),
              ),
              actions: [
                if (nftEntity.ownedCollection)
                  IconButton(
                    onPressed: onEnterChat,
                    icon: DefaultImage(
                      path: "assets/icons/chat.svg",
                      width: 32,
                      height: 32,
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 72.0,
                      child: CachedNetworkImage(
                        imageUrl: nftEntity.collectionLogo,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg3.withOpacity(0.5),
                      ),
                      child: Text(
                        nftEntity.name,
                        textAlign: TextAlign.center,
                        style: fontBody2Bold(),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                expandedTitleScale: 1.0,
              ),
              bottom: TabBar(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(vertical: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: fontTitle07SemiBold(color: fore1),
                unselectedLabelStyle: fontTitle07(color: fore3),
                indicatorColor: fore3,
                dividerColor: fore5,
                indicatorWeight: 1.0,
                tabs: const [
                  Tab(text: "커뮤니티"),
                  Tab(text: "멤버"),
                ],
              ),
            ),
          ];
        },
        body: Container(
          color: bg1,
          child: TabBarView(
            children: [
              if (infoLoading)
                Lottie.asset(
                  'assets/lottie/loader.json',
                )
              else if (infoError)
                CommunityErrorView(onRetry: onRetry)
              else
                _CommunityInfoView(
                    onTapRank: onTapRank,
                    koreanNumFormat: koreanNumFormat,
                    nftEntity: nftEntity,
                    benefitCount: benefitCount,
                    nftBenefits: nftBenefits,
                    nftNetwork: nftNetwork),
              Container(
                color: bg1,
                child: membersLoading
                    ? Lottie.asset(
                        'assets/lottie/loader.json',
                      )
                    : membersError
                        ? CommunityErrorView(onRetry: onRetry)
                        : true
                            ? ListView(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32.0,
                                  horizontal: 16.0,
                                ),
                                children: [
                                  Text('총 0명',
                                      style: fontTitle07Medium(color: fore1)),
                                  SizedBox(
                                    height: 183,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        DefaultImage(
                                          path: 'assets/images/hmp_eyes_up.svg',
                                          height: 60,
                                          width: 60,
                                        ),
                                        Text('아직 가입한 멤버가 없어요',
                                            style: fontTitle07(color: fore3)),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                itemCount: communityMembers.length,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32.0,
                                  horizontal: 16.0,
                                ),
                                separatorBuilder: (context, index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  height: 1.0,
                                  width: double.infinity,
                                  color: fore5.withOpacity(0.05),
                                ),
                                itemBuilder: (context, index) {
                                  final member = communityMembers[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (index == 0)
                                        Text('총 $membersCount명',
                                            style: fontTitle07Medium(
                                                color: fore1)),
                                      GestureDetector(
                                        onTap: () => onMemberTap(member),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: Row(
                                            children: [
                                              CustomImageView(
                                                svgPath:
                                                    'assets/images/hmp_eyes_up.svg',
                                                height: 48.0,
                                                width: 48.0,
                                              ),
                                              const SizedBox(width: 12.5),
                                              Expanded(
                                                  child: Text(member.name,
                                                      style:
                                                          fontTitle07SemiBold())),
                                              const SizedBox(width: 16),
                                              DefaultImage(
                                                path:
                                                    'assets/icons/arrow_right.svg',
                                                height: 24.0,
                                                width: 24.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityInfoView extends StatefulWidget {
  const _CommunityInfoView({
    super.key,
    required this.onTapRank,
    required this.koreanNumFormat,
    required this.nftEntity,
    required this.benefitCount,
    required this.nftBenefits,
    required this.nftNetwork,
  });

  final NumberFormat koreanNumFormat;
  final TopCollectionNftEntity nftEntity;
  final int benefitCount;
  final List<BenefitEntity> nftBenefits;
  final NftNetworkEntity nftNetwork;
  final VoidCallback onTapRank;

  @override
  State<_CommunityInfoView> createState() => _CommunityInfoViewState();
}

class _CommunityInfoViewState extends State<_CommunityInfoView> {
  bool _benefitsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 32.0),
          color: bg1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('포인트', style: fontTitle06Medium()),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: bgNega4,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('총 포인트', style: fontCompactXs(color: fore2)),
                            const SizedBox(height: 4),
                            Text(
                                '${widget.koreanNumFormat.format(widget.nftEntity.totalPoints)} P',
                                style: fontBoldEmpty(color: fore1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onTapRank,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: bgNega4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('포인트 랭킹 ',
                                      style: fontCompactXs(color: fore2)),
                                  const SizedBox(height: 2),
                                  DefaultImage(
                                    path: 'assets/icons/arrow_right.svg',
                                    width: 14.0,
                                    height: 14.0,
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  '${widget.koreanNumFormat.format(widget.nftEntity.communityRank)}위',
                                  style: fontBoldEmpty(color: fore1)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Container(
          color: bgNega5,
          height: 8.0,
          width: double.infinity,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
          color: bg1,
          child: Column(
            children: [
              Row(
                children: [
                  DefaultImage(
                    path: 'assets/icons/blue_tick.svg',
                    height: 20.0,
                    width: 20.0,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '혜택',
                    style: fontTitle06Medium(),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    widget.benefitCount.toString(),
                    style: fontTitle07(color: fore2),
                  )
                ],
              ),
              if (widget.nftBenefits.isEmpty)
                const SizedBox()
              else
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _benefitsExpanded ? widget.nftBenefits.length : 1,
                  itemBuilder: (context, index) {
                    final benefit = widget.nftBenefits[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 68.0,
                            height: 68.0,
                            child: CustomImageView(
                              url: benefit.spaceImage,
                              width: 68.0,
                              height: 68.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                benefit.description,
                                style: fontTitle07Medium(color: fore2),
                              ),
                              const SizedBox(height: 4.0),
                              SizedBox(
                                height: 43.0,
                                child: Text(
                                  benefit.spaceName,
                                  style: fontCompactSm(color: fore3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 1.0,
                color: fore5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _benefitsExpanded = !_benefitsExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '더보기',
                        style: fontBody2Xs(),
                      ),
                      const SizedBox(width: 2.0),
                      Transform.rotate(
                        angle: _benefitsExpanded ? 3.14 : 0,
                        child: DefaultImage(
                          path: "assets/icons/ic_arrow_down.svg",
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          color: bgNega5,
          height: 8.0,
          width: double.infinity,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
          color: bg1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이벤트 히스토리', style: fontTitle06Medium()),
              const SizedBox(height: 16.0),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                  image: DecorationImage(
                    image: AssetImage("assets/images/event-bg-1.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("03/09(토) 13:00", style: fontCompactXs()),
                        const SizedBox(height: 10),
                        Text("Web3 Wednesday with WEMIX",
                            style: fontTitle04Bold()),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CustomImageView(
                              width: 20,
                              height: 20,
                              svgPath: "assets/icons/ic_space_disabled.svg",
                            ),
                            Text("하이드미 플리즈 을지로",
                                style: fontCompactSm(color: fore2)),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: DefaultButton(
                                      height: 36,
                                      onTap: () {},
                                      title: "신청 가능",
                                      color: bg1,
                                      textColor: hmpBlue,
                                      borderRadius: 4,
                                      textStyle: fontCompactSm(color: hmpBlue),
                                      iconWidget: Container(
                                        height: 4,
                                        width: 4,
                                        decoration: const BoxDecoration(
                                          color: hmpBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const HorizontalSpace(5),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: CustomImageView(
                                          width: 20,
                                          height: 20,
                                          imagePath: "assets/images/img1.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-5, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CustomImageView(
                                            width: 20,
                                            height: 20,
                                            imagePath: "assets/images/img2.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: const Offset(-10, 0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CustomImageView(
                                            width: 20,
                                            height: 20,
                                            imagePath: "assets/images/img3.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "53명 모집됨",
                                    style: fontCompactSm(),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                CustomImageView(
                                  width: 40,
                                  height: 40,
                                  radius: BorderRadius.circular(4.0),
                                  imagePath: "assets/images/img3.png",
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  left: 3.0,
                                  top: 3.0,
                                  child: DefaultImage(
                                    path:
                                        "assets/chain-logos/ethereum_chain.svg",
                                    height: 14,
                                    width: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < 2; i++)
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/event-bg-2.png")),
                  ),
                  foregroundDecoration: const BoxDecoration(
                    color: Colors.grey,
                    backgroundBlendMode: BlendMode.saturation,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('03/09(토) 13:00',
                            maxLines: 1, style: fontCompactXs()),
                        const SizedBox(height: 4.0),
                        Text('Web3 Wednesday with WEMIX',
                            maxLines: 2, style: fontTitle04Bold()),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            DefaultImage(
                              path: 'assets/icons/location.svg',
                              width: 16.0,
                              height: 16.0,
                            ),
                            const SizedBox(width: 2.0),
                            Text('하이드미 플리즈 을지로',
                                maxLines: 1,
                                style: fontCompactSm(color: fore2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          color: bgNega5,
          height: 8.0,
          width: double.infinity,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 100.0),
          color: bg1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('상세 정보', style: fontTitle06Medium()),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('네트워크', style: fontTitle07(color: fore2)),
                  Expanded(
                    child: Text(widget.nftNetwork.network,
                        textAlign: TextAlign.end, style: fontTitle07()),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text('홀더 수', style: fontTitle07(color: fore2)),
                  Expanded(
                    child: Text(
                        widget.koreanNumFormat.format(
                            int.tryParse(widget.nftNetwork.holderCount) ?? 0),
                        textAlign: TextAlign.end,
                        style: fontTitle07()),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text('바닥가', style: fontTitle07(color: fore2)),
                  Expanded(
                    child: Text(
                        '${NumberFormat("###,###,###.##", "en_US").format(num.parse(widget.nftNetwork.floorPrice))} ${widget.nftNetwork.symbol.toUpperCase()}',
                        textAlign: TextAlign.end,
                        style: fontTitle07()),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ],
    );
  }
}

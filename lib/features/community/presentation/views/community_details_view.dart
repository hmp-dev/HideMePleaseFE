import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/features/community/domain/entities/community_member_entity.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';
import 'package:mobile/features/nft/domain/entities/nft_network_entity.dart';

class CommunityDetailsView extends StatelessWidget {
  final VoidCallback onEnterChat;
  final VoidCallback onRetry;
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
                background: Center(
                  child: Text(
                    nftEntity.name,
                    style: fontBody2Bold(),
                    maxLines: 2,
                  ),
                ),
                expandedTitleScale: 1.0,
              ),
              bottom: TabBar(
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(vertical: 19.5),
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
          color: bgNega5,
          child: TabBarView(
            children: [
              if (infoLoading)
                Lottie.asset(
                  'assets/lottie/loader.json',
                )
              else if (infoError)
                _ErrorView(onRetry: onRetry)
              else
                _CommunityInfoView(
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
                        ? _ErrorView(onRetry: onRetry)
                        : communityMembers.isEmpty
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
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(height: 12.0),
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
                                  // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  height: 1.0,
                                  color: fore5,
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
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
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
          color: bg1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이벤트 히스토리', style: fontTitle06Medium()),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('03/09(토) 13:00', maxLines: 1, style: fontCompactXs()),
                    const SizedBox(height: 4.0),
                    Text('Web3 Wednesday with WEMIX',
                        maxLines: 2, style: fontTitle04Bold()),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        DefaultImage(
                          path: 'assets/icons/location.svg',
                          width: 16.0,
                          height: 16.0,
                        ),
                        const SizedBox(width: 2.0),
                        Text('하이드미 플리즈 을지로',
                            maxLines: 1, style: fontCompactSm(color: fore2)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
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
                        '${widget.koreanNumFormat.format(widget.nftNetwork.floorPrice)} KLAY',
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({this.message = '뭔가 잘못됐어', required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 183,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: fontTitle07(color: fore3)),
          const SizedBox(height: 16.0),
          HMPCustomButton(
            bgColor: backgroundGr1,
            text: '다시 장전하다',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

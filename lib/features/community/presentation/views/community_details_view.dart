import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';

class CommunityDetailsView extends StatelessWidget {
  final VoidCallback onEnterChat;
  final TopCollectionNftEntity nftEntity;
  const CommunityDetailsView({
    super.key,
    required this.onEnterChat,
    required this.nftEntity,
  });

  @override
  Widget build(BuildContext context) {
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
              ListView(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('총 포인트',
                                          style: fontCompactXs(color: fore2)),
                                      const SizedBox(height: 4),
                                      Text('9,991 P',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('포인트 랭킹 ',
                                              style:
                                                  fontCompactXs(color: fore2)),
                                          const SizedBox(height: 2),
                                          DefaultImage(
                                            path:
                                                'assets/icons/arrow_right.svg',
                                            width: 14.0,
                                            height: 14.0,
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('7위',
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
                              '23',
                              style: fontTitle07(color: fore2),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            children: [
                              const SizedBox(width: 68.0, height: 68.0),
                              const SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '매일 한 잔의 커피나 음료 20% 할인',
                                    style: fontTitle07Medium(color: fore2),
                                  ),
                                  const SizedBox(height: 4.0),
                                  SizedBox(
                                    height: 43.0,
                                    child: Text(
                                      'Hide me, please 을지로',
                                      style: fontCompactSm(color: fore3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          height: 1.0,
                          color: fore5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextButton(
                            onPressed: () {},
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
                                DefaultImage(
                                  path: "assets/icons/ic_arrow_down.svg",
                                  width: 16,
                                  height: 16,
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
                              Text('03/09(토) 13:00',
                                  maxLines: 1, style: fontCompactXs()),
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
                                      maxLines: 1,
                                      style: fontCompactSm(color: fore2)),
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
                              child: Text('Klaytn',
                                  textAlign: TextAlign.end,
                                  style: fontTitle07()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            Text('홀더 수', style: fontTitle07(color: fore2)),
                            Expanded(
                              child: Text('1,308',
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
                              child: Text('0 KLAY',
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
              ),
              ListView(
                children: const [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

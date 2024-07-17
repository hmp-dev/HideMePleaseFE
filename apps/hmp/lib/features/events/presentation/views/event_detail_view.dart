import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/thick_divider.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/events/presentation/widgets/event_member_item_widget.dart';
import 'package:mobile/features/events/presentation/widgets/only_badge_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventDetailView extends StatefulWidget {
  const EventDetailView({
    super.key,
    required this.onRefresh,
    required this.bannerImage,
  });

  final Future<void> Function() onRefresh;
  final String bannerImage;

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final ScrollController _scrollController = ScrollController();
  final CarouselController _carouselController = CarouselController();
  final _pageController = PageController(initialPage: 0);

  bool isAgreeWithTerms = false;

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
      // widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                (1 != 1)
                    ? CustomImageView(
                        imagePath: "assets/images/place_holder_card.png",
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        radius: BorderRadius.circular(2),
                        fit: BoxFit.cover,
                      )
                    : CustomImageView(
                        imagePath: widget.bannerImage,
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        radius: BorderRadius.circular(2),
                        fit: BoxFit.cover,
                      ),
                buildBackArrowIconButton(context),
              ],
            ),
          ),
          buildHeaderSection(),
          buildContentSectionTitle(),
          buildMembersSection(),
        ],
      ),
    );
  }

  SliverToBoxAdapter buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Web3 Wednesday with WEMIX",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: fontTitle03Bold(),
            ),
            const VerticalSpace(16),
            Text(
              "웹 3의 혁신적인 세계를 만나보세요! 저희는 최신 기술과 창의적인 아이디어를 결합한 오프라인 행사를 소개합니다. 이곳에서는 블록체인, 디지털 자산, 메타버스와 같은 핵심 주제에 대해 논의하고, 실제로 체험해 볼 수 있는 기회를 제공합니다.",
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style: fontCompactMd(),
            ),
            const VerticalSpace(20),
            const OnlyBadgeItem(
              imgPath: "assets/images/outcasts.png",
            )
          ],
        ),
      ),
    );
  }

  Positioned buildBackArrowIconButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 28,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 10,
              blurRadius: 10,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: DefaultImage(
              path: "assets/icons/img_icon_arrow.svg",
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContentSectionTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 16, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "이벤트 신청 현황",
              style: fontTitle07Medium(),
            ),
            const SizedBox(width: 10),
            Text(
              "23",
              style: fontTitle07(color: fore2),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMembersSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 380,
              viewportFraction: 1,
              aspectRatio: 16 / 9,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              enlargeFactor: 0.15,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (int index, _) {
                "$index".log();
              },
            ),
            items: [
              buildEventMembers(),
              buildEventMembers(),
              buildEventMembers(),
              buildEventMembers(),
              buildEventMembers()
            ],
          ),
          SmoothPageIndicator(
            controller: _pageController, // PageController
            count: 5,
            effect: const WormEffect(
              activeDotColor: hmpBlue,
              dotColor: fore4,
              dotHeight: 8.0,
              dotWidth: 8.0,
              spacing: 10.0,
            ), // your preferred effect
            onDotClicked: (index) {},
          ),
          const VerticalSpace(10),
          const ThickDivider(),
        ],
      ),
    );
  }

  Widget buildEventMembers() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: eventMembers.length,
          itemBuilder: (context, index) {
            return EventMemberItemWidget(
              memberTempDto: eventMembers[index],
              isLastItem: index == eventMembers.length - 1,
            );
          }),
    );
  }
}

class EventMemberTempDto {
  final String name;
  final String pfpImage;

  const EventMemberTempDto({
    required this.name,
    required this.pfpImage,
  });
}

List<EventMemberTempDto> eventMembers = [
  const EventMemberTempDto(
    name: "박하사탕맛있어",
    pfpImage: "assets/images/member-pfp-1.png",
  ),
  const EventMemberTempDto(
    name: "대담한고릴라",
    pfpImage: "assets/images/member-pfp-2.png",
  ),
  const EventMemberTempDto(
    name: "거부할수없는루시퍼",
    pfpImage: "assets/images/member-pfp-3.png",
  ),
  const EventMemberTempDto(
    name: "lovelovely99",
    pfpImage: "assets/images/member-pfp-4.png",
  ),
  const EventMemberTempDto(
    name: "몽키몽키매직몽키매직",
    pfpImage: "assets/images/member-pfp-5.png",
  )
];

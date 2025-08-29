import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/helpers/map_utils.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/custom_image_view.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';
import 'package:mobile/features/common/presentation/widgets/thick_divider.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/events/presentation/widgets/dot_indicator.dart';
import 'package:mobile/features/events/presentation/widgets/event_member_item_widget.dart';
import 'package:mobile/features/events/presentation/widgets/only_badge_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/generated/locale_keys.g.dart';

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
  int _activeIndex = 0;
  List<Marker> allMarkers = [];

  late GoogleMapController _controller;

  String transactionNote = "";
  String receiptImgUrl = "";

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.5518911, 126.9917937),
    zoom: 12,
  );

  bool isAgreeWithTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  Future<void> moveAnimateToAddress(LatLng position) async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 92.8334901395799,
          target: position,
          tilt: 9.440717697143555,
          zoom: 18.151926040649414,
        ),
      ),
    );
  }

  Future<void> addMarker(LatLng position) async {
    allMarkers
        .add(Marker(markerId: const MarkerId('myMarker'), position: position));
    setState(() {});
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
          buildFeaturesList(),
          SliverToBoxAdapter(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: IgnorePointer(
                ignoring: false, // onTap을 위해 false로 설정, 필요시 true로 변경
                child: GoogleMap(
                  initialCameraPosition: _kGooglePlex,
                  markers: Set.from(allMarkers),
                  onMapCreated: (GoogleMapController controller) async {
                    setState(() {
                      _controller = controller;
                    });

                    const latLong = LatLng(37.567947, 126.9907);
                    await moveAnimateToAddress(latLong);
                    await addMarker(latLong);
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  indoorViewEnabled: true,
                  onTap: (argument) {
                    MapUtils.openMap(37.567947, 126.9907);
                  },
                ),
              ),
            ),
          ),
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
                setState(() => _activeIndex = index);
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
          DotIndicator(
            activeIndex: _activeIndex,
            listSize: 5,
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

  Widget buildFeaturesList() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상세 안내',
              style: fontTitle06Medium(),
            ),
            const VerticalSpace(20),
            const EventFeatureValueWidget(
              keyText: "진행 일자",
              valueText: "03/09(토) 11:50~17:00",
            ),
            const EventFeatureValueWidget(
              keyText: "신청 기간",
              valueText: "03/07(목) 11:50까지",
            ),
            const EventFeatureValueWidget(
              keyText: LocaleKeys.place.tr(),
              valueText: "하이드미 플리즈 을지로점 3층",
            ),
            const EventFeatureValueWidget(
              keyText: "NFT",
              valueText: "DADAZ only",
            ),
            const EventFeatureValueWidget(
              keyText: LocaleKeys.benefit.tr(),
              valueText: "커피 한잔, 디저트 1개",
            ),
            const EventFeatureValueWidget(
              keyText: "참가 비용",
              valueText: "20,000원",
            ),
            const EventFeatureValueWidget(
              keyText: "결제 정보",
              valueText: "현장 결제 (계좌이체 가능)",
            ),
            const VerticalSpace(30),
          ],
        ),
      ),
    );
  }
}

class EventFeatureValueWidget extends StatelessWidget {
  const EventFeatureValueWidget({
    super.key,
    required this.keyText,
    required this.valueText,
  });

  final String keyText;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              keyText,
              style: fontCompactSm(color: fore3),
            ),
          ),
          Text(
            valueText,
            style: fontCompactSm(),
          ),
        ],
      ),
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

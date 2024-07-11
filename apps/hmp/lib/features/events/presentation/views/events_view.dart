import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/alarms_icon_button.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/events/presentation/screens/event_detail_screen.dart';
import 'package:mobile/features/events/presentation/widgets/event_widget.dart';
import 'package:mobile/features/my/presentation/widgets/rounded_select_button.dart';

class EventsView extends StatefulWidget {
  const EventsView({
    super.key,
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  final ScrollController _scrollController = ScrollController();

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
          SliverToBoxAdapter(child: buildTopTitleBar()),
          SliverToBoxAdapter(child: buildEventTypeSelectButtonRow()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    side: const BorderSide(color: fore3),
                    activeColor: hmpBlue,
                    checkColor: white,
                    value: false,
                    onChanged: (bool? value) {
                      setState(() {
                        isAgreeWithTerms = value ?? false;
                      });
                    },
                  ),
                  Text(
                    "진행 중인 이벤트만 보기",
                    style: fontCompactMd(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: buildTopHmpBlueBannerBox(),
          ),
          SliverToBoxAdapter(child: buildEventList()),
        ],
      ),
    );
  }

  Widget buildTopHmpBlueBannerBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: hmpBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "커뮤니티에 이벤트가 필요한 순간이라면",
                  style: fontCompactSmMedium(color: fore2),
                ),
                const VerticalSpace(7),
                Text(
                  "이벤트 제안을 통해 함께 숨어보세요",
                  style: fontCompactMdBold(),
                ),
              ],
            ),
          ),
        ),
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
            Text("Join me", style: fontBody2Bold()),
            const AlarmsIconButton(),
          ],
        ),
      ),
    );
  }

  buildEventList() {
    // make a Column with list of 5 EventWidget
    return Column(
      children: List.generate(
          5,
          (index) => EventWidget(
                onTap: () {
                  EventDetailScreen.push(context);
                },
                bgImage: "assets/images/event-bg-${index + 1}.png",
              )),
    );
  }

  Widget buildEventTypeSelectButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: [
          RoundedSelectButton(
            title: "전체",
            isSelected: true,
            onTap: () {},
          ),
          RoundedSelectButton(
            title: "참여 가능한",
            isSelected: false,
            onTap: () {},
          ),
          RoundedSelectButton(
            title: "신청한",
            isSelected: false,
            onTap: () {},
          ),
          RoundedSelectButton(
            title: "참여한",
            isSelected: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

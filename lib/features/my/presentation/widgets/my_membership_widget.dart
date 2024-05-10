import 'package:flutter/material.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';
import 'package:mobile/features/my/presentation/widgets/members_item_widget.dart';

class MyMembershipWidget extends StatefulWidget {
  const MyMembershipWidget({super.key});

  @override
  State<MyMembershipWidget> createState() => _MyMembershipWidgetState();
}

class _MyMembershipWidgetState extends State<MyMembershipWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              return MembersItemWidget(
                name: "Outcasts",
                imagePath: "",
                communityPoints: "2,000 P",
                communityRanking: "12위",
                isLastItem: index == 3,
                usersCount: 120,
              );
            },
          ),
        ),
      ],
    );
  }
}

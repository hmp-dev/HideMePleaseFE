import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/vertical_space.dart';

class MemberWidget extends StatefulWidget {
  const MemberWidget({super.key});

  @override
  State<MemberWidget> createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(20),
        Row(
          children: [
            Text("포인트 랭킹", style: fontTitle06Medium()),
          ],
        ),
      ],
    );
  }
}
